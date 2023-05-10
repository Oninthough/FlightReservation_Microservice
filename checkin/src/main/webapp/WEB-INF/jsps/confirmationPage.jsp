<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Boarding Pass</title>

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

p {
    color: #333;
    font-size: 18px;
    margin-bottom: 0;
}

.boarding-pass {
    margin-top: 20px;
    border: 1px solid #333;
    padding: 10px;
    border-radius: 5px;
}

.boarding-pass p {
    margin-top: 0;
    margin-bottom: 10px;
}

.button {
    display: inline-block;
    padding: 10px 20px;
    margin-top: 20px;
    background-color: #007bff;
    color: #ffffff;
    text-decoration: none;
    border-radius: 5px;
    transition: background-color 0.3s ease;
}

.button:hover {
    background-color: #0056b3;
}
</style>

</head>
<body>
<div class="container">
    <h2>Boarding Pass</h2>
    <div class="boarding-pass">
        <p>Passenger Name: ${reservation.getPassanger().getFirstName() }</p>
        <p>Flight Number: ${reservation.getFlight().getFlightNumber()}</p>
        <p>Departure Airport: ${reservation.getFlight().getDepartureCity()}</p>
        <p>Arrival Airport: ${reservation.getFlight().getArrivalCity()}</p>
        <p>Boarding Time: ${reservation.getFlight().getEstimatedDepartureTime()}</p>
    </div>
    <a href="GeneratePdf" class="button">Print Boarding Pass</a>
</div>
</body>
</html>
