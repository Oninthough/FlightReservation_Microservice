<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Booking page</title>
<style>
body {
    font-family: Arial, sans-serif;
    background-color: #f5f5f5;
}

.container {
    width: 800px;
    margin: 0 auto;
    padding: 20px;
    background-color: #ffffff;
    box-shadow: 0px 0px 5px #ccc;
    border-radius: 5px;
}

h2 {
    text-align: center;
}

form {
    margin-top: 20px;
}

table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 10px;
}

table th,
table td {
    padding: 10px;
    border: 1px solid #ccc;
    text-align: left;
}

input[type="text"],
input[type="number"],
input[type="date"] {
    width: 100%;
    padding: 10px;
    margin-bottom: 10px;
    border: 1px solid #ccc;
    border-radius: 3px;
    outline: none;
}

input[type="submit"] {
    background-color: #007bff;
    color: #ffffff;
    border: none;
    padding: 10px;
    cursor: pointer;
    border-radius: 3px;
    font-size: 16px;
    margin-top: 10px;
}

pre {
    white-space: pre-wrap;
}

</style>
</head>
<body>
<div class="container">
    <h2>Flight Details</h2>
    <table>
        <tr>
            <th>Flight No.</th>
            <th>Airline</th>
            <th>Departure</th>
            <th>Arrival</th>
            <th>Time of Departure</th>
        </tr>
        <tr>
            <td>${flight.flightNumber}</td>
            <td>${flight.operatingAirlines}</td>
            <td>${flight.departureCity}</td>
            <td>${flight.arrivalCity}</td>
            <td>${flight.estimatedDepartureTime}</td>
        </tr>
    </table>

    <h2>Passenger Details</h2>
    <form action="completeReservation" method="post">
        <table>
            <tr>
                <td>First Name</td>
                <td><input type="text" name="firstName" /></td>
            </tr>
            <tr>
                <td>Middle Name</td>
                <td><input type="text" name="middleName" /></td>
            </tr>
            <tr>
                <td>Last Name</td>
                <td><input type="text" name="lastName" /></td>
            </tr>
            <tr>
                <td>Email ID</td>
                <td><input type="text" name="email" /></td>
            </tr>
            <tr>
                <td>Phone Number</td>
                <td><input type="text" name="phone" /></td>
            </tr>
            <tr>
                <td></td>
                <td><input type="hidden" name="flightId" value="${flight.id}" /></td>
                            </tr>
        </table>

        <h4>Enter The Payment Details</h4>
        <table>
            <tr>
                <td>Name On Card</td>
                <td><input type="text" name="nameOnCard" /></td>
            </tr>
            <tr>
                <td>Card Number</td>
                <td><input type="number" name="cardNumber" /></td>
            </tr>
            <tr>
                <td>CVV</td>
                <td><input type="number" name="cvv" /></td>
            </tr>
            <tr>
                <td>Expiry Date</td>
                <td><input type="date" name="expiryDate" /></td>
            </tr>
            <tr>
                <td></td>
                <td><input type="submit" value="Complete Reservation" /></td>
            </tr>
        </table>
    </form>
</div>
</body>
</html>
                
