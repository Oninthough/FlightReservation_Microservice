package com.flight_reservation_app.repository;

import java.util.Date;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.flight_reservation_app.entities.Flight;

public interface FlightRepository extends JpaRepository<Flight, Long> {
	//helps us to define how we want to perform search operation. used it inside repository layer to build custom method findFlight 
	//inside it 1st is entity class field name, 2nd is the variable of @param ie arrivalCity,...

	@Query("from Flight where departureCity=:departureCity and arrivalCity=:arrivalCity and dateOfDeparture=:dateOfDeparture" )
	//"flights" is table name from database. it signifies from flight table find the flights with given condition(1 is entity field 2 is comming from controller)

	List<Flight> findFlights(@Param("arrivalCity") String to, @Param("departureCity")String from, @Param("dateOfDeparture")Date departureDate);
//to is coping into arrivalCity, from into departureCity, departuredate into dateOfDeparture with the help of @Param then it will be given to @Query
}
