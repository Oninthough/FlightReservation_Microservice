<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Display Flight page</title>
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

table {
    width: 100%;
    margin-top: 20px;
    border-collapse: collapse;
}

th, td {
    padding: 8px;
    text-align: left;
    border-bottom: 1px solid #ccc;
}

th {
    background-color: #007bff;
    color: #ffffff;
}

a {
    text-decoration: none;
    color: #007bff;
}

a:hover {
    text-decoration: underline;
}

</style>
</head>
<body>
<div class="container">
    <h2>Flight Search Result</h2>
    <table>
        <tr>
            <th>Airline</th>
            <th>Departure City</th>
            <th>Arrival City</th>
            <th>Departure Time</th>
            <th>Select Flight</th>
        </tr>
        <c:forEach items="${findFlight}" var="findFlight">
            <tr>
                <td>${findFlight.operatingAirlines}</td>
                <td>${findFlight.departureCity}</td>
                <td>${findFlight.arrivalCity}</td>
                <td>${findFlight.estimatedDepartureTime}</td>
                <td><a href="selectFlight?flightId=${findFlight.id}">Select</a></td>
            </tr>
        </c:forEach>
    </table>
</div>
</body>
</html>
