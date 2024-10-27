The setup will include red herring flags in various web directories and the real flag hidden within a MySQL database, which can only be accessed via SQL injection.
Step 1: Set Up the Apache2 Web Server and MySQL Database

Install Apache2 and MySQL First, ensure your server has Apache2 and MySQL installed and running. You’ll also need PHP and necessary modules to create dynamic webpages.

```bash
sudo apt update
sudo apt install apache2 mysql-server php libapache2-mod-php php-mysql
```
Start Apache2 and MySQL

```bash
sudo systemctl start apache2
sudo systemctl start mysql
```
Step 2: Create the MySQL Database for the Challenge

Log into MySQL as Root

```bash
sudo mysql -u root -p
```
Create a Database and User Table

Create a database named ctf_challenge and a table to store user credentials along with the real flag.

```sql

CREATE DATABASE ctf_challenge;
USE ctf_challenge;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50),
    password VARCHAR(50),
    flag VARCHAR(255)
);
```
Insert Admin Credentials and Real Flag

Insert an admin user with a placeholder password and store the real flag within the table.

```sql

    INSERT INTO users (username, password, flag) 
    VALUES ('admin', 'password123', 'FLAG{REAL_SQL_INJECTION_FLAG}');
```
    Exit MySQL when done.

Step 3: Create a Vulnerable Login Page

This login page will allow participants to bypass authentication using SQL injection.

    Create the PHP Login Script

    Create the login.php file in the Apache web root directory (/var/www/html/).

    ```bash

    sudo nano /var/www/html/login.php
    ```
Insert the following PHP code, which contains a SQL injection vulnerability:

```php

    <?php
    // Database connection
    $host = 'localhost';
    $db = 'ctf_challenge';
    $user = 'root';
    $pass = '';

    $conn = new mysqli($host, $user, $pass, $db);

    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        $username = $_POST['username'];
        $password = $_POST['password'];

        $query = "SELECT * FROM users WHERE username='$username' AND password='$password'";
        $result = $conn->query($query);

        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();
            echo "Login successful! Welcome, " . $row['username'] . "<br>";
            echo "Your flag is: " . $row['flag'];
        } else {
            echo "Invalid login credentials!";
        }
    }
    ?>

    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Login</title>
    </head>
    <body>
        <h2>Login Page</h2>
        <form method="POST" action="">
            Username: <input type="text" name="username"><br>
            Password: <input type="password" name="password"><br>
            <input type="submit" value="Login">
        </form>
    </body>
    </html>
```
    This page allows login attempts, but SQL queries are not sanitized, allowing SQL injection.

Step 4: Set Up Red Herring Flags

Place multiple red herring flags across the server in visible web directories. These will serve to distract participants from the real goal.

    Create Fake Flag Directories and Files

    You can organize red herring flags in different folders and formats (text files, HTML files, images, videos). Start by creating the directories.

    ```bash
    sudo mkdir -p /var/www/html/fake_flags/images
    sudo mkdir -p /var/www/html/fake_flags/text_files
    ```
Create Red Herring Flag Files

Create several text, HTML, and image files that display fake flags.

```bash

sudo nano /var/www/html/fake_flags/fake1.txt
```
Add the following content to the file:


```bash
This is not the real flag. Fake flag: FLAG{FAKE_FLAG_1}
```
Repeat this for other files (fake2.txt, fake_image.jpg, etc.), adding fake flag content in different locations. You can use tools like exiftool to add metadata to image files with more fake flags.

Create HTML Pages Displaying Fake Flags

You can also create HTML pages with embedded fake flags:

```bash

sudo nano /var/www/html/fake_flags/fake_flag1.html

Insert the following HTML:

html

    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Fake Flag 1</title>
    </head>
    <body>
        <h1>This is not the real flag.</h1>
        <p>Fake flag: FLAG{FAKE_FLAG_1}</p>
    </body>
    </html>
```
    These fake flags will mislead participants while they explore the directories.

Step 5: Configure a Misconfigured Firewall

Create a misconfigured firewall setup that allows access to services like MySQL and SSH, but restricts HTTPS to force participants to use HTTP.

    Enable and Configure UFW

    Enable UFW and configure the rules as follows:

    ```bash

    sudo ufw enable
    sudo ufw default deny incoming
    sudo ufw allow 80/tcp    # Allow HTTP
    sudo ufw allow 3306/tcp  # Leave MySQL open for exploration
    sudo ufw allow 22/tcp    # Leave SSH open for SSH access
    sudo ufw deny 443/tcp    # Block HTTPS (forces HTTP)
    ```
Step 6: Testing the Challenge

    Test the Vulnerable Login Page
        Navigate to http://<server-ip>/login.php and try entering credentials like admin/password123 to see if it works.
        Then, try SQL injection using the payload: admin' OR '1'='1 to bypass authentication.

    Test the Red Herrings
        Use tools like curl and dirb to find the directories and confirm that fake flags are accessible.
