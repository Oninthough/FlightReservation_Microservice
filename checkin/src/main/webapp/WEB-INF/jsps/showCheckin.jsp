<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Check-in for Reserved Passenger</title>

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

mark {
    display: block;
    margin-top: 10px;
    margin-bottom: 20px;
    background-color: #ffc107;
    padding: 10px;
    font-weight: bold;
}

label {
    display: block;
    margin-bottom: 10px;
}

input[type="text"], input[type="submit"] {
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
    <h2>Check-in for Reserved Passenger</h2>
    <mark><b>Check-in starts before 48 hours of scheduled time</b></mark>
    <form action="startCheckin" method="post">
        <label>Enter Reservation ID <input type="text" name="id"></label>
        <input type="submit" value="Proceed">
    </form>
</div>
</body>
</html>
