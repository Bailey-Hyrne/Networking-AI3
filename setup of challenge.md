Step 1: Install Apache and MySQL (LAMP Stack)
Before setting up the vulnerable PHP page, ensure you have a LAMP (Linux, Apache, MySQL, PHP) stack installed on your machine. If it’s not already installed, follow these steps to install it.

1.1 Install Apache Web Server
```bash
sudo apt update
sudo apt install apache2
```

1.2 Install MySQL Server
```bash
sudo apt install mysql-server
```

1.3 Install PHP and Required Extensions
```bash
sudo apt install php php-mysqli libapache2-mod-php
```

1.4 Restart Apache to Apply Changes
```bash
sudo systemctl restart apache2
```

Step 2: Configure MySQL Database
Create a MySQL database and a users table for storing login credentials.

2.1 Log in to MySQL
```bash
sudo mysql -u root -p
```
2.2 Create the Database
```sql
CREATE DATABASE ctf_challenge;
```
2.3 Create the users Table
```sql
USE ctf_challenge;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    flag VARCHAR(255) DEFAULT NULL
);
```
2.4 Insert Users
Insert the users into the users table with a vulnerable SELECT query. The admin account will contain the real flag.

```sql
INSERT INTO users (username, password, flag) 
VALUES 
    ('KingCeo', 'SigmaWolf123', NULL),
    ('Ted Smith', 'Hacked123', NULL),
    ('admin', 'password123', '402acb1c3e3f37da6e1bb6cacadc315d'); -- real flag hidden under admin
```
2.5 Exit MySQL
```sql
EXIT;
```
Step 3: Create the Vulnerable Login Page
Create the vulnerable login.php file that allows for SQL injection.

3.1 Create login.php File
```bash
sudo nano /var/www/html/login.php
```
3.2 Add the Vulnerable PHP Code
Insert the following PHP code into login.php:
```php
Copy code
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

    // Vulnerable query
    $query = "SELECT * FROM users WHERE username='$username' AND password='$password'";
    $result = $conn->query($query);

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        echo "Login successful! Welcome, " . $row['username'] . "<br>";
        if ($row['flag']) {
            echo "Your flag is: " . $row['flag'];
        }
    } else {
        echo "Invalid login credentials!";
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login Page</title>
</head>
<body>
    <h2>Login</h2>
    <form method="POST" action="">
        Username: <input type="text" name="username"><br>
        Password: <input type="password" name="password"><br>
        <input type="submit" value="Login">
    </form>
</body>
</html>
```
3.3 Save and Close the File
Press CTRL+X, then Y to save the file and exit.

Step 4: Create Fake Flag Files (Red Herrings)
Set up directories and files that will serve as fake flags to mislead users during their exploration.

4.1 Create Directories for Fake Flags
```bash
Copy code
sudo mkdir -p /var/www/html/fake_flags/images
sudo mkdir -p /var/www/html/fake_flags/text_files
```

4.2 Create Fake Flag Files (will add some more files with memes later)
```bash
Copy code
echo "This is not the real flag. Fake flag: FLAG{FAKE_FLAG_1}" | sudo tee /var/www/html/fake_flags/text_files/fake1.txt
echo "FLAG{FAKE_FLAG_2}" | sudo tee /var/www/html/fake_flags/text_files/fake2.txt
```

4.3 Create Fake Flag HTML Pages
Create fake_flag1.html and other similar fake pages.
```bash
sudo nano /var/www/html/fake_flags/fake_flag1.html
```
Add this content:

```html
Copy code
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
Repeat the process for additional fake flag pages (fake_flag2.html, etc.).

Step 5: Configure the Misconfigured Firewall
Set up UFW (Uncomplicated Firewall) to expose MySQL and restrict services as intended.

5.1 Enable UFW and Expose MySQL Port
```bash
sudo ufw enable
sudo ufw allow 3306/tcp     # Allow MySQL port
```
5.2 Restrict Other Services
```bash
sudo ufw allow 80/tcp       # Allow HTTP
sudo ufw deny 443/tcp       # Block HTTPS
sudo ufw allow from 192.168.1.100 to any port 22  # Restrict SSH to a specific IP (optional)
sudo ufw default deny incoming  # Deny all other incoming traffic
```
5.3 Check UFW Status
```bash
Copy code
sudo ufw status
```

5.4 Restart UFW to Apply Changes
```bash
sudo ufw reload
```
Step 6: Test the Challenge
Now, it's time to test the challenge and verify everything is working.

6.1 Access the Login Page
Open a web browser and navigate to http://<server-ip>/login.php.

Try the default credentials:

Username: KingCeo, Password: SigmaWolf123
Username: Ted Smith, Password: Hacked123
Test SQL injection:

Try entering admin' OR '1'='1 as the password to exploit the vulnerability and log in as admin to access the real flag.
6.2 Explore Red Herrings
Use curl or a directory scanner like dirb to search for /fake_flags/ and view the fake flag files.

6.3 Verify Database Exposure
You can use nmap to verify that port 3306 (MySQL) is exposed to the public:

```bash
nmap -p 3306 <server-ip>
```
Step 7: Verify Challenge Completion
Log in as admin to view the real flag: 402acb1c3e3f37da6e1bb6cacadc315d.
Test the SQL injection vulnerability with admin' OR '1'='1.
Check for the fake flags under /fake_flags/.

Security Disclaimer
This setup intentionally creates vulnerabilities for controlled practice. It should never be used in production environments. Always secure your systems after completing the challenge setup.
