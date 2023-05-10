<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Login page</title>
<style>
    body {
        font-family: Arial, sans-serif;
        background-color: #f2f2f2;
    }

    .login-container {
        width: 300px;
        margin: 0 auto;
        background-color: #fff;
        padding: 20px;
        border-radius: 5px;
        box-shadow: 0px 0px 5px rgba(0, 0, 0, 0.2);
        display: grid;
        gap: 10px;
    }

    .login-container h2 {
        color: #333;
        text-align: center;
        margin-top: 0;
    }

    .login-container form {
        display: grid;
        gap: 10px;
    }

    .login-container label {
        font-weight: bold;
    }

    .login-container input[type="text"],
    .login-container input[type="password"],
    .login-container input[type="submit"] {
        width: 100%;
        padding: 10px;
        margin-bottom: 10px;
        border: 1px solid #ccc;
        border-radius: 3px;
    }

    .login-container input[type="submit"] {
        background-color: #007bff;
        color: #fff;
        cursor: pointer;
    }

    .login-container input[type="submit"]:hover {
        background-color: #0056b3;
    }
</style>
</head>
<body>
    <div class="login-container">
        <h2>Login here....</h2>
        <form action="newLog" method="post">
            <label for="emailId">User Id</label>
            <input type="text" name="emailId" id="emailId" />
            <label for="password">Password</label>
            <input type="password" name="password" id="password" />
            <input type="submit" value="Login" />
        </form>
        <div>${msg}</div>
    </div>
</body]
</html>
