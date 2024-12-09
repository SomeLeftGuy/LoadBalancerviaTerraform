<!DOCTYPE html>
<!--
 Copyright 2021 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&display=swap" rel="stylesheet">
    <title>Basic Load Balancer Page</title>
    <style>
        body {
            background-color: green;
            color: white;
            font-family: "Bebas Neue", cursive;
        }
        main {
            margin: 20px auto;
            width: 600px;
            text-align: center;
        }
        h1 {
            font-size: 75px;
        }
        p {
            font-weight: 900;
            font-size: 60px;
        }
        strong {
            color: lightblue;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
            color: white;
        }
        th, td {
            border: 1px solid white;
            padding: 10px;
            text-align: center;
        }
        @media only screen and (min-width : 850px) {
            main {
                width: 800px;
            }
            h1 {
                font-size: 150px;
            }
            p {
                font-size: 75px;
            }
        }
        @media only screen and (max-width : 480px) {
            main {
                width: 300px;
            }
            h1 {
                font-size: 45px;
            }
            p {
                font-size: 20px;
            }
        }
    </style>
</head>
<body>
    <main>
        <h1>Greetings!</h1>
        <p>This page is load balanced. The only difference between the pages served up by these different nodes is that this one is served up by <strong><?php echo gethostname(); ?></strong></p>

        <h2>Data from the Demo Table:</h2>
        <?php
        $servername = "34.118.105.244"; // Cloud SQL Public IP
        $username = "admin";            // Database username
        $password = "admin";            // Database password
        $dbname = "demo";               // Database name

        // Create connection
        $conn = new mysqli($servername, $username, $password, $dbname);

        // Check connection
        if ($conn->connect_error) {
            die("<p>Connection failed: " . $conn->connect_error . "</p>");
        }

        // Query to fetch data from the demo_table
        $sql = "SELECT * FROM demo_table";
        $result = $conn->query($sql);

        // Display data in a table if available
        if ($result->num_rows > 0) {
            echo "<table><tr><th>ID</th><th>Data</th></tr>";
            while ($row = $result->fetch_assoc()) {
                echo "<tr><td>" . $row["id"] . "</td><td>" . $row["data"] . "</td></tr>";
            }
            echo "</table>";
        } else {
            echo "<p>No data available</p>";
        }

        // Close connection
        $conn->close();
        ?>
    </main>
</body>
</html>
