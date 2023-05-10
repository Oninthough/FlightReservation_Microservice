<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Reservation Details</title>

<style>
/* CSS styles go here */
body {
    font-family: Arial, sans-serif;
    background-color: #f8f9fa;
    margin: 0;
    padding: 0;
}

.container {
    max-width: 600px;
    margin: 100px auto;
    padding: 20px;
    background-color: #ffffff;
    border-radius: 5px;
    box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
}

h2 {
    color: #007bff;
    font-size: 24px;
    margin-top: 0;
}

label {
    display: block;
    margin-bottom: 10px;
}

input[type="number"], input[type="checkbox"], input[type="submit"] {
    margin-top: 5px;
    margin-bottom: 10px;
}

input[type="submit"] {
    display: inline-block;
    padding: 10px 20px;
    background-color: #007bff;
    color: #ffffff;
    text-decoration: none;
    border-radius: 5px;
    transition: background-color 0.3s ease;
    cursor: pointer;
}

input[type="submit"]:hover {
    background-color: #0056b3;
}
</style>

</head>
<body>
<div class="container">
    <h2>Reservation Details</h2>
    <label>Passenger's Name: ${reservation.getPassanger().getFirstName()}</label>
    <label>Passenger's Email Id: ${reservation.getPassanger().getEmail()}</label>
    <label>Passenger's Contact: ${reservation.getPassanger().getPhone()}</label>
    <label>Operating Airline: ${reservation.getFlight().getOperatingAirlines()}</label>
    <label>Flight Number: ${reservation.getFlight().getFlightNumber()}</label>
    <label>Departure City: ${reservation.getFlight().getDepartureCity()}</label>
    <label>Arrival City: ${reservation.getFlight().getArrivalCity()}</label>
    <label>Date Of Departure: ${reservation.getFlight().getDateOfDeparture()}</label>

    <h2>Update Number of Bags and Status</h2>
    <form action="checkIn" method="post">
        <input type="hidden" name="id" value="${reservation.getId()}"/>
        <label>Number of Bags <input type="number" name="numberOfBags"></label>
        <label>Checked In Status <input type="checkbox" name="checkedIn"></label>
        <input type="submit" value="Confirm">
    </form>
</div>
</body>
</html>
