# FlightReservation_Microservice
Here we have created two seperate project in Spring boot. Following business flow first flight_reservation_app will be exicuted

which will be used to save passanger,fligt details and ticket reservation is done through this project. for that OneToOne mapping is done between passanger and flight

Pdf ticket generation and mailing the same is implemented where external api integretion is done.

After ticket reservation is done the flight and passanger details(ie. reservation details) is sent through a rest Controller, that api can be test in Postman

Fetched that api to checkin project using RestTemplate and formed tha Reservation object back.using that checkin module is created

and boarding pass is generated at the end



from __future__ import annotations
from datetime import datetime
from airflow.operators.bash_operator import BashOperator
from airflow.operators.empty import EmptyOperator
import os
from google.cloud import secretmanager
import json
from urllib.parse import urlparse
from google.cloud import storage
import google.auth
import mysql.connector
import subprocess
import shlex
from concurrent.futures import ThreadPoolExecutor
from airflow.models import Variable
from datetime import datetime
from airflow.decorators import task
from airflow.models.dag import DAG
from utils.maf.alerting_utils import send_email
import re
from datetime import datetime, timedelta

cred = google.auth.default()
project_id = cred[1]

maf_bucket_name = Variable.get("maf_bucket_name")
prefix = Variable.get("maf_files_prefix")
# secretsname = os.environ.get("secretspath")
secretmanagerPath = Variable.get("secret_manager_path")
environment = "Test"

default_dag_args = {
    'retries': 1,
    'retry_delay': 1,
     'email_on_failure': True,
    'email_on_retry': True,
    'email': re.split("[,;]", "@EMAIL_DIST;vijaykumar.p@transunion.com"),
}

def storage_client():
    """
      Create a GCS storage client
    """
    storage_client = storage.Client()
    return storage_client

def get_db_config():
    print(f"In get_db_config")
    client = secretmanager.SecretManagerServiceClient()
    print(f"client::>> {client}")
    # name = f"projects/100799677285/secrets/maf-db-secret/versions/latest"
    name = secret_manager_path

    try:
        # response = client.access_secret_version(name=secretsname)
        response = client.access_secret_version(name=name)
        secret = response.payload.data.decode('UTF-8')
        secret_dict = json.loads(secret)
        print(f"secret_dict::>> {secret_dict}")
        total_url = secret_dict["mysql_jdbc-url"]
        parsed_url = urlparse(total_url)
        parsed_url_path = urlparse(parsed_url.path)

        return {
            'user': secret_dict["mysql_username"],
            'password': secret_dict["mysql_password"],
            'host': parsed_url_path.hostname,
            'port': parsed_url_path.port,
            'database': parsed_url_path.path.lstrip('/'), 
            'ssl_ca':"/home/airflow/gcs/data/certs/server-ca.pem",
            'ssl_cert':"/home/airflow/gcs/data/certs/client-cert.pem",
            'ssl_key':"/home/airflow/gcs/data/certs/client-key.pem"
        }
    
    except Exception as e:
        print(f"Error retrieving secrets: {e}")
        raise

def initialize_maf_master_table(num_of_files):
    config = get_db_config()

    # try:
    #     with mysql.connector.connect(**config) as conn:
    #         with conn.cursor() as cursor:
    #             start_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    #             insert_query = '''
    #             INSERT INTO maf_master_data_run (num_of_files, total_records, success_count, failure_count, status, start_date, end_date)
    #             VALUES (%s, %s, %s, %s, %s, %s, %s)
    #             '''
    #             cursor.execute(insert_query, (num_of_files, 0, 0, 0, 0, start_date, None))
    #             conn.commit()

    #             cursor.execute("SELECT LAST_INSERT_ID()")
    #             run_id = cursor.fetchone()[0]
    #             return run_id

    # except mysql.connector.Error as err:
    #     print(f"Error: {err}")

    try:
        conn = mysql.connector.connect(**config)
        cursor = conn.cursor()
        start_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        print(f"start_date initialize_maf_master_table ::>> {start_date}")
        insert_query = '''
        INSERT INTO maf_master_data_run (num_of_files, total_records, success_count, failure_count, status, start_date, end_date)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        '''
        cursor.execute(insert_query, (num_of_files, 0, 0, 0, 0, start_date, None))
        conn.commit()

        cursor.execute("SELECT LAST_INSERT_ID()")
        run_id = cursor.fetchone()[0]
        return run_id

    except mysql.connector.Error as err:
        print(f"Error: {err}")
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

def update_maf_master_table(run_id,num_of_files):
    config = get_db_config()
    status = 1
    try:
        conn = mysql.connector.connect(**config)
        cursor = conn.cursor()

        aggregation_query = '''
            SELECT 
                SUM(total_records) as total_records,
                SUM(success_count) as success_count,
                SUM(failure_count) as failure_count,
                MAX(end_date) as end_date,
                MAX(start_date) as start_date
            FROM 
                maf_file_process_run
            WHERE 
                run_id = %s
            '''

        cursor.execute(aggregation_query, (run_id,))
        result = cursor.fetchone()
        total_records, success_count, failure_count, end_date,start_date = result

        if result:
            # Calculate the time difference
            duration = end_date - start_date

            update_query = '''
            UPDATE 
                maf_master_data_run
            SET 
                total_records = %s,
                success_count = %s,
                failure_count = %s,
                end_date = %s,
                status = %s,
                num_of_files = %s
            WHERE 
                run_id = %s
            '''

            cursor.execute(update_query, (int(total_records), int(success_count), int(failure_count), end_date, 1, num_of_files,run_id))
            conn.commit()
            print(f"Master Maf table updated for RunId {run_id}")
        else:
            status = 0
            print(f"Conditions not met for updating RunId{run_id} in Master Maf Table")
           
    except mysql.connector.Error as err:
        status = 0
        print(f"Error: {err}")
    finally:
        send_email(total_records, success_count, failure_count, end_date,start_date, status, num_of_files, run_id, duration)
        if conn.is_connected():
            cursor.close()
            conn.close()

def download_file_from_gcs(source_file, destinatoin_file):
    client = storage_client()
    # bucket = client.bucket('maf-dev-test')
    bucket = client.bucket(maf_bucket_name)
    blob = bucket.blob(source_file)
    blob.download_to_filename(destinatoin_file)
    print(f'File {source_file} downloaded to {destinatoin_file}')

# Define the function to delete the file
def delete_file(file_path):
    if os.path.exists(file_path):
        os.remove(file_path)
        print(f'File {file_path} deleted successfully.')
    else:
        print(f'File {file_path} does not exist.')

def run_java(file_name, run_id):
    """
    This function will call the Java class with the file name as a parameter.
    """
    print(f"file name from run_java::>> {file_name}")
    
    print(f"Run id::>> {run_id}")

    filename=file_name.split('/')[-1]
    tmpfilename = f"/tmp/{filename}"
    print(f"Temporary file::>> {tmpfilename}")
    download_file_from_gcs(file_name, tmpfilename)

    java_command = f"java -cp /home/airflow/gcs/data/lib/*:/home/airflow/gcs/data/MafLoader-1.0-SNAPSHOT.jar com.nis.data.pipeline.maf.MafLoader {tmpfilename} {run_id}"
    # java_command = f"java -cp /home/airflow/gcs/data/lib/*:/home/airflow/gcs/data/MafFileReader-1.0-SNAPSHOT.jar com.nis.data.pipeline.address.App gs://{maf_bucket_name}/{file_name}"
    command_args = shlex.split(java_command)

    # Capture the output and error streams
    process = subprocess.run(command_args, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    # Print the output and error streams to the Airflow logs
    print(process.stdout)
    print(process.stderr)

    # Check if the subprocess completed successfully
    process.check_returncode()    
    delete_file(tmpfilename)
    # return success_count, failure_count

# @task(task_id="process_file")
def process_file(file_name):
    """
    This function will be executed for each file retrieved from the GCS bucket.
    Replace this with your actual processing logic.
    """
    print(f"Processing file::>> {file_name}")
    # Your file processing logic goes here


# def process_maf_files(**kwargs):
#     ti = kwargs['ti']
#     parquetFiles = ti.xcom_pull(task_ids='get_files_from_gcs')
#     num_files = len(parquetFiles)
#     print(f"Number of files after getting from pull function: {num_files}")
#     with ThreadPoolExecutor(max_workers=num_files) as executor:
#         futures = [executor.submit(run_java, file_name) for file_name in parquetFiles]
#         print(f"Number of futures: {len(futures)}")
#         for future in futures:
#             future.result()

    #     java_tasks = []
    #     for idx, future in enumerate(futures):
    #         java_command = future.result()
    #         call_java_task = BashOperator(
    #             task_id=f'call_java_task_{idx}',
    #             bash_command=java_command,
    #             dag=DAG
    #         )
    #         java_tasks.append(call_java_task)

    # for task in java_tasks:
    #     task.execute(context={})
with DAG('maf_data_loader', schedule_interval='@once', start_date=datetime(2024, 6, 27), default_args=default_dag_args) as dag:

    @task(task_id="get_files_from_gcs")
    def get_files_from_gcs(**kwargs):
        """
        This function used fir read the file names from gcs bucket which ends with .parquet
        and which returns latest filename.
        """
        client = storage_client()
        print(f"maf bucket name : {maf_bucket_name}")
        bucket = client.bucket(maf_bucket_name)
        # filenames = bucket.list_blobs(prefix="version=800/instance_id=3293488/obs_date=2024-06-19/")
        # print(f"Prefix : {{var.value.maf_files_prefix}}")
        print(f"Prefix : {prefix}")
        filenames = bucket.list_blobs(prefix={prefix})
        files = [filename.name for filename in filenames if filename.name.endswith(".parquet")]
        print(f"file names are : {files}")
        num_files = len(files)
        print(f"Number of files: {num_files}")
        run_id =initialize_maf_master_table(num_files)
        print(f"run_id: {run_id}")
        ti = kwargs.get('ti')
        ti.xcom_push(key='num_files', value=num_files)
        ti.xcom_push(key='run_id', value=run_id)
        return files
    
    # setenv = BashOperator(
        # task_id='setenv',
        # bash_command='gsutil cp gs://maf-data-processor-dags-bucket-9ab1/jars/MafLoader-1.0-SNAPSHOT.jar /home/airflow/gcs/data/MafLoader-1.0-SNAPSHOT.jar',
        # bash_command='gsutil cp gs://{{ var.value.jar_src_path }} {{ var.value.jar_dst_path }}',
        # bash_command="""
        #     gsutil cp gs://maf-data-processor-dags-bucket-9ab1/jars/MafLoader-1.0-SNAPSHOT.jar /home/airflow/gcs/data/MafLoader-1.0-SNAPSHOT.jar
        #     gsutil cp gs://maf-dev-test-bucket/key/cf-address-terraform.json /tmp/key/cf-address-terraform.json
        # """,
        # dag=dag)
        # bash_command="""
            # gsutil cp gs://maf-dev-test-bucket/key/cf-address-terraform.json /tmp/key/cf-address-terraform.json
        # """,
        # dag=dag)



    @task(task_id="process_maf_file")
    def process_maf_file(file_name, **kwargs):
        ti = kwargs['ti']
        run_id = ti.xcom_pull(task_ids='get_files_from_gcs', key='run_id')
        run_java(file_name, run_id)
        # success_count, failure_count = run_java(file_name)
        # global total_success_count
        # global total_failure_count
        # print(f"Before incrementing Success count: {total_success_count}, Failure count: {total_failure_count}")
        # total_success_count += success_count
        # total_failure_count += failure_count
        # print(f"Success count: {total_success_count}, Failure count: {total_failure_count}")
        # return total_success_count, total_failure_count
        # Push the counts to XCom
        # ti = kwargs['ti']
        # ti.xcom_push(key='total_success_count', value=total_success_count)
        # ti.xcom_push(key='total_failure_count', value=total_failure_count)

    @task(task_id="finalize")
    def finalize(**kwargs):
        ti = kwargs['ti']
        run_id = ti.xcom_pull(task_ids='get_files_from_gcs', key='run_id')
        num_of_files = ti.xcom_pull(task_ids='get_files_from_gcs', key='num_files')
        print(f"Run id::>> {run_id}")
        print(f"Number of files::>> {num_of_files}")
        start_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        end_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        print(f"start_date::>> {start_date}")
        print(f"end_date::>> {end_date}")
        update_maf_master_table(run_id, num_of_files)

    end = EmptyOperator(task_id="end")
    file_list = get_files_from_gcs()
    process_maf = process_maf_file.expand(file_name=file_list)

    

    process_maf >> finalize() >> end
........................
package com.nis.data.pipeline.maf;

import com.nis.data.pipeline.maf.loader.AddressLoader;
import com.nis.data.pipeline.maf.loader.Zip5Loader;
import com.nis.data.pipeline.maf.loader.Zip9Loader;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import com.nis.data.pipeline.maf.exception.AppRuntimeException;

import java.time.LocalDateTime;

public class MafLoader {
    private static final Logger log = LogManager.getLogger(MafLoader.class);
    private static String secretsManagerPath = null;

    public static void main(String[] args) {
        LocalDateTime mainMethodStartLocalDateTime = LocalDateTime.now();
        log.info("Time before starting:: {}", mainMethodStartLocalDateTime);
        String filename = null;
//        String filename = "C:\\Users\\makhtar\\work\\nis.dataloaders.maf\\src\\main\\resources\\MAF_Output_v5.parquet";
//        String filename = "C:\\work\\parquetTestFiles\\maf10k.parquet";
        String runId = null;
//        String pathToZip5File = "C:\\Users\\makhtar\\work\\nis.dataloaders.maf\\src\\main\\resources\\MAFZipSummary.dat";
//        String pathToZip9File = "C:\\Users\\makhtar\\work\\nis.dataloaders.maf\\src\\main\\resources\\MAFZip4Summary.dat";
        if (args != null && args.length > 0) {
            filename = args[0];
            runId = args[1];
            secretsManagerPath = args[2];
        }
        if (runId == null) {
            throw new AppRuntimeException("Run Id cannot be null or empty");
        }
        if (filename == null) {
            throw new AppRuntimeException("filename cannot be null or empty");
        }
        if (secretsManagerPath == null) {
            throw new RuntimeException("secrets path not found");
        }
        //The filename and path are same so passing both as 'filename'
//        System.out.println("ADDRESS LOADER STARTING");
        AddressLoader addressLoader = new AddressLoader();
        addressLoader.loadAddressMafFile(new MafLoader(), runId, filename, LocalDateTime.now());
//        System.out.println("ADDRESS LOADER ENDED");
//        System.out.println("ZIP5SUMMARY LOADER STARTING");
//        Zip5Loader zip5Loader = new Zip5Loader();
//        zip5Loader.loadZip5File(new MafLoader(), runId, pathToZip5File, LocalDateTime.now());
//        System.out.println("ZIP5SUMMARY LOADER ENDED");
//        System.out.println("ZIP9SUMMARY LOADER STARTING");
//        Zip9Loader zip9Loader = new Zip9Loader();
//        zip9Loader.loadZip9File(new MafLoader(), runId, pathToZip9File, LocalDateTime.now());
//        System.out.println("ZIP9SUMMARY LOADER ENDED");

    }

    public String getSecretManagerPath() {
        return secretsManagerPath;
    }

}
........
syntax = "proto3";

option java_package = "nis.databuild";
option java_outer_classname = "nis.databuild.AddressAccessor";

option csharp_namespace = "Nis.DB.nis.databuild.AddressAccessor";

enum E1MatchPrecision {
  NO_MATCH = 0;
  ZIP11 = 1;
  ZIP9 = 2;
  ZIP7 = 3;
  BLOCK_GROUP = 4;
  ZIP5 = 5;
}

enum AddressType {
  STREET = 0;
  FIRM = 1;
  RURAL_ROUTE = 2;
  HIGHRISE = 3;
  PO_BOX = 4;
  GENERAL_DELIVERY = 5;
  UNKNOWN = 6;
}

message Zip5Summary {
  uint32 zip_code = 1; // The 5-digit zip code
  uint32 business_delivery_count = 2;
  uint32 residential_delivery_count = 3;
  uint32 unknown_delivery_count = 4;
  int32 business_phone_count = 5;
  int32 residential_phone_count = 6;
  int32 e1_segment = 7;
  E1MatchPrecision e1_match_precision = 8;
}

message Zip9Summary {
  uint32 zip_plus_4_code = 1; // The 9-digit zip code
  uint32 business_delivery_count = 2;
  uint32 residential_delivery_count = 3;
  uint32 unknown_delivery_count = 4;
  int32 business_phone_count = 5;
  int32 residential_phone_count = 6;
  AddressType address_type = 7;
  int32 e1_segment = 8;
  E1MatchPrecision e1_match_precision = 9;
}

// This is used by the converter and loader service to load new records.
message AddressLoadRecord {
  enum Action {
    ADD_OR_UPDATE_RECORD = 0;
    DELETE_RECORD = 1;
  }
  Action action = 1;

  uint32 address_id = 3;

  Address address = 5;
  Zip5Summary zip5_summary = 6;
  Zip9Summary zip9_summary = 7;
}

// For index tables that point to the main table
message AddressIndex {
  repeated AddressIndexRecord address_index_record = 2;
}

message AddressIndexRecord {
  uint32 address_id = 1;
}

// The address record
message Address {
  int64 last_update_time = 1;	// DateTime Ticks

  uint32 address_id = 2; // Also known as 'persistent ID' or MAF PID

  int64 dpc = 4;

  string building_number = 5;
  string pre_directional = 6;
  string street_name = 7;
  string street_type = 8;
  string post_directional = 9;

  string secondary_type = 10;
  string secondary_number = 11;

  string city_name = 12;

  string state_abbreviation = 13;

  int64 dpv_confirm_date_ticks = 14;

  AddressType address_type = 15;

  enum DpvConfirmCode {
    NOT_CONFIRMED = 0;
    BUILDING_CONFIRMED = 1;
    CONFIRMED = 2;
  }
  DpvConfirmCode dpv_confirm_code = 16;

  enum LACSLinkConfirmCode {
    UNKNOWN = 0;
    NOT_FOUND = 1;
    MATCHED_WITHOUT_SECONDARY_INFORMATION = 2;
    MATCHED = 3;
  }
  LACSLinkConfirmCode lacslink_confirm_code = 17;

  enum GovernmentBuildingIndicator {
    NONE_OR_UNKNOWN_GOVERNMENT_BUILDING = 0;
    CITY_GOVERNMENT_BUILDING = 1;
    FEDERAL_GOVERNMENT_BUILDING = 2;
    STATE_GOVERNMENT_BUILDING = 3;
    FIRM_ONLY = 4;
    CITY_GOVERNMENT_BUILDING_AND_FIRM_ONLY = 5;
    FEDERAL_GOVERNMENT_BUILDING_AND_FIRM_ONLY = 6;
    STATE_GOVERNMENT_BUILDING_AND_FIRM_ONLY = 7;
  }
  GovernmentBuildingIndicator government_building_indicator = 18;

  bool is_alternate_record = 19;

  enum ResidenceBusinessIndicator {
    UNKNOWN_RBDI = 0;
    BUSINESS = 1;
    RESIDENCE = 2;
    DUAL = 3;
  }
  ResidenceBusinessIndicator residence_or_business_indicator = 20;

  enum DuplicateIndicator {
    NOT_A_DUPLICATE = 0;
    FIRST_LISTED_DUPLICATE = 1;
    NON_FIRST_LISTED_DUPLICATE = 2;
  }
  DuplicateIndicator duplicate_indicator = 21;

  int32 biz_phone_count = 22;
  int32 res_phone_count = 23;

  int32 e1_segment = 24;
  E1MatchPrecision e1_match_precision = 25;

  double latitude = 26;
  double longitude = 27;

  enum LatLonMatchPrecision {
    UNKNOWN_PRECISION = 0;
    AUX_FILE_DATA_LOCATION = 1;			// Doesn't appear to be in the data
    APP_INFERS_FROM_CANDIDATES = 2;
    POINT_LEVEL = 3;
    STREET_RANGE = 4;
    INTERSECTION = 5;
    ZIP5_CENTROID = 6;
    ZIP7_CENTROID = 7;
    ZIP9_CENTROID = 8;
    STREET_CENTROID_BLOCK_GROUP = 9;				// Doesn't appear to be in the data
    STREET_CENTROID_CENSUS_TRACT = 10;				// Doesn't appear to be in the data
    STREET_CENTROID_UNCLASSIFIED_ZIP = 11;			// Doesn't appear to be in the data
    STREET_CENTROID_UNCLASSIFIED_FINANCE_AREA = 12;	// Doesn't appear to be in the data
    STREET_CENTROID_UNCLASSIFIED_CITY = 13;			// Doesn't appear to be in the data
  }
  LatLonMatchPrecision match_precision = 28;

  int32 published_biz_phone_count = 29;
  int32 published_res_phone_count = 30;
  int32 published_dual_phone_count = 31;

  enum SohoIndicator {
    NO_SOHO = 0;
    HIGHLY_PROBABLE_SOHO = 1;
    PROBABLE_SOHO = 2;
    POTENTIAL_SMALL_OFFICE = 3;
    SMALL_BUSINESS_UNKNOWN_ADDRESS = 4;
  }
  SohoIndicator single_home_office_indicator = 32;

  bool is_building = 33;

  enum VacancyIndicator {
    UNKNOWN_VACANCY = 0;
    NOT_VACANT = 1;
    VACANT = 2;
  }
  VacancyIndicator vacancy_indicator = 34;

  enum CMRAIndicator { // Mail drop
    NON_CMRA = 0;
    CMRA = 1;
    BOTH = 2;
    HAS_CMRA_TENANT = 3;
  }
  CMRAIndicator cmra_indicator = 35;

  bool is_prison = 36;

  int32 business_e1_segment = 37;
  E1MatchPrecision business_e1_match_precision = 38;

  string carrier_route = 39;

  int64 default_zip9 = 40;

  string firm_name = 41;

  uint32 default_address_id = 42;

  enum DoNotMailIndicator {
    NONE = 0;
    ONLY_CATALOG =  2;
    ONLY_PRINT_MEDIA = 4;
    CATALOG_PRINT_MEDIA = 6;
    ONLY_OTHER_MAIL = 8;
    CATALOG_OTHER_MAIL = 10;
    PRINT_MEDIA_OTHER_MAIL = 12;
    CATALOG_PRINT_MEDIA_OTHER_MAIL = 14;
    DECEASED_CATALOG_PRINT_MEDIA_OTHER_MAIL = 15;
    //OTHER_MEDIA = 1;
    //PRINT_MEDIA = 2;
    //CATALOG = 4;
    //DECEASED = 8;
  }
  DoNotMailIndicator do_not_mail_indicator = 43;

  string building_name = 44;

  enum NetAssetValue {
    NAV_0_TO_24_999 = 0;				// 'A'
    NAV_25_000_TO_49_999 = 1;			// 'B'
    NAV_50_000_TO_74_999 = 2;			// 'C'
    NAV_75_000_TO_99_999 = 3;			// 'D'
    NAV_100_000_TO_249_999 = 4;			// 'E'
    NAV_250_000_TO_499_999 = 5;			// 'F'
    NAV_500_000_TO_749_999 = 6;			// 'G'
    NAV_750_000_TO_999_999 = 7;			// 'H'
    NAV_1_000_000_TO_1_999_999 = 8;		// 'I'
    NAV_2_000_000_OR_MORE = 9;			// 'J'
  }
  NetAssetValue net_asset_value = 45;

  enum NetAssetValueMatchCode
  {
    NAV_NONE = 0;
    NAV_ZIP11 = 1;
    NAV_ZIP9 = 2;
    NAV_ZIP7 = 3;
    NAV_BLOCK_GROUP = 4;
    NAV_ZIP = 5;
  }
  NetAssetValueMatchCode nav_code = 46;

  bool observes_dst = 47;

  enum TimeZone {
    NOT_APPLICABLE = 0;
    SAMOA = 1;
    HAWAII = 2;
    ALASKA_YUKON = 3;
    PACIFIC = 4;
    MOUNTAIN = 5;
    CENTRAL = 6;
    EASTERN = 7;
    ATLANTIC = 8;
    NEWFOUNDLAND = 9;
  }
  TimeZone time_zone = 48;

  enum FinSegMatchPrecision {
    FIN_SEG_NO_MATCH = 0;
    FIN_SEG_ZIP11 = 1;
    FIN_SEG_ZIP9 = 2;
    FIN_SEG_ZIP7 = 3;
    FIN_SEG_BLOCK_GROUP = 4;
    FIN_SEG_ZIP5 = 5;
  }
  FinSegMatchPrecision financial_segment_match_precision = 49;

  int32 financial_segment = 50;

  string census_2010_state_and_county = 51;
  string census_2010_tract_and_block_group = 52;
  string census_2010_block_id = 53;

  string census_2020_state_and_county = 54;
  string census_2020_tract_and_block_group = 55;
  string census_2020_block_id = 56;

  string buying_power_score_bps = 57;
  string bps_credit_flag = 58;

}
