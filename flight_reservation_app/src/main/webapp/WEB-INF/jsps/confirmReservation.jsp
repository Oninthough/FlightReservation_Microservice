<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Confirmation</title>
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

.confirmation {
    text-align: center;
    margin-top: 30px;
    font-size: 18px;
    padding: 20px;
    background-color: #e6f7ff;
    border: 1px solid #007bff;
    border-radius: 5px;
}

.reservation-id {
    font-size: 24px;
    margin-top: 10px;
    font-weight: bold;
    color: #007bff;
}

.home-button {
    display: block;
    margin-top: 20px;
    text-align: center;
}

.home-button a {
    display: inline-block;
    padding: 10px 20px;
    background-color: #007bff;
    color: #ffffff;
    text-decoration: none;
    border-radius: 5px;
    transition: background-color 0.3s ease;
}

.home-button a:hover {
    background-color: #0056b3;
}
</style>
</head>
<body>
<div class="container">
    <h2>Confirmation Status</h2>
    <div class="confirmation">
        Your Ticket Is Booked<br>
        Your Reservation ID is: <span class="reservation-id">${reservedId}</span>
        
    </div>
    <div class="home-button">
        <a href="http://localhost:8080/flights/">Home</a>
    </div>
</div>

</body>
</html>
