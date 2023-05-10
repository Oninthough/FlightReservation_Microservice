<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Search Flight</title>
<style>
body {
    font-family: Arial, sans-serif;
    background-color: #f5f5f5;
}

.container {
    width: 400px;
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

label {
    display: block;
    margin-bottom: 10px;
}

input[type="text"], input[type="submit"] {
    width: 100%;
    padding: 8px;
    border: 1px solid #ccc;
    border-radius: 3px;
}

input[type="submit"] {
    background-color: #007bff;
    color: #ffffff;
    font-weight: bold;
    cursor: pointer;
}

input[type="submit"]:hover {
    background-color: #0056b3;
}

</style>
</head>
<body>
<div class="container">
    <h2>Flight Details</h2>
    <form action="findFlights" method="post">
        <label>From: <input type="text" name="from"></label>
        <label>To: <input type="text" name="to"></label>
        <label>Departure Date: <input type="text" name="departureDate"></label>
        <input type="submit" value="Search">
    </form>
</div>
</body>
</html>
