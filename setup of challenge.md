Step 1: Install Apache and MySQL (LAMP Stack)
If you haven’t already installed Apache, MySQL, and PHP, follow these steps:

Install Apache Web Server
```bash
sudo apt update
sudo apt install apache2
```
Install MySQL Server
```bash
sudo apt install mysql-server
```
Install PHP and Required Extensions
```bash
sudo apt install php php-mysqli libapache2-mod-php
```
Restart Apache to Apply Changes
```bash
sudo systemctl restart apache2
```
Step 2: Configure MySQL Database
Log in to MySQL
```bash
sudo mysql
```
Create the Database
```sql
CREATE DATABASE ctf_challenge;
```
Create a Database User
```sql
CREATE USER 'ctf_user'@'localhost' IDENTIFIED BY 'secure_password';

GRANT ALL PRIVILEGES ON ctf_challenge.* TO 'ctf_user'@'localhost';
FLUSH PRIVILEGES;
```

Create the users Table
```sql
USE ctf_challenge;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    flag VARCHAR(255) DEFAULT NULL
);

INSERT INTO users (username, password, flag) 
VALUES 
    ('KingCeo', 'SigmaWolf123', NULL),
    ('Ted Smith', 'Hacked123', NULL),
    ('admin', 'password123', '402acb1c3e3f37da6e1bb6cacadc315d'); -- real flag hidden under admin
```
Exit MySQL
```sql
EXIT;
```
Step 3: Create the Vulnerable Login Page
Create login.php File
```bash
sudo nano /var/www/html/login.php
```
Add the Vulnerable PHP Code
```php
<?php
// Database connection
$host = 'localhost';
$db = 'ctf_challenge';
$user = 'ctf_user';
$pass = 'secure_password';

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$flag = ''; // Variable to store the flag

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Vulnerable query without escaping inputs
    $username = $_POST['username'];
    $password = $_POST['password'];

    $query = "SELECT * FROM users WHERE username='$username' AND password='$password'";
    $result = $conn->query($query);

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        
        // If the user is admin, show the flag
        if ($row['username'] == 'admin') {
            $flag = $row['flag'];
            echo "<h1>Welcome, " . htmlspecialchars($username) . "!</h1>";
            echo "<p>Congratulations! You have found the real flag: <strong>" . $flag . "</strong></p>";
        } else {
            // For KingCeo and Ted Smith, redirect to index.html
            header("Location: /index.html");
            exit();
        }
    } else {
        echo "<p>Invalid login credentials!</p>";
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
Save and Close the File

Step 4: Create index.html
Create index.html File
```bash
sudo nano /var/www/html/index.html
```
Add HTML Content
Insert the following HTML content into the file:
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CTF Challenge</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <h1>Welcome to the CTF Challenge</h1>
        <p>This challenge is designed to test your skills in web security and SQL injection techniques. Your goal is to find the real flag hidden in the system.</p>

        <h2>Scenario</h2>
        <p>You have gained access to a vulnerable web server. The administrator left several files exposed, and some login credentials may lead you to discover valuable information.</p>

        <h2>Hints</h2>
        <ul>
            <li>Some users in the database may have special privileges. Attempt to escalate access by using SQL injection techniques.</li>
            <li>Look out for unusual files or directories. There may be some decoys placed to throw you off track.</li>
            <li>Use <code>nmap</code> to check which ports are open. Port 3306 (MySQL) may hold useful information.</li>
        </ul>
        <p>Good luck, and happy hacking!</p>
    </div>
</body>
</html>
```
Save and Close the File


Step 5: Create Fake Flag Files (Red Herrings)
Create Directories for Fake Flags
```bash
sudo mkdir -p /var/www/html/images
sudo mkdir -p /var/www/html/text_files
sudo mkdir -p /var/www/html/videos
```
Create Fake Flag Files
```bash
echo <a href="https://raw.githubusercontent.com/Bailey-Hyrne/Networking-AI3/refs/heads/main/goofy1.webp">Flaig</a> | sudo tee /var/www/html/images/flag11514.html

echo "Every morning I wake up and I turn on my computer. I put my sunglasses on because the light hurts my eyes. I put on my typing gloves. I connect to the internet web through 8 proxies and then I hack until sundown. I'm probably the best hacker I know; I've hit banks, schools, doctors offices, oil tanks, farms, FedEx, Walmart, KFC, grocery stores. You name it, I probably hacked into it. I even have it set up where I can see the grocery transactions in my term window as they happen. I have 6 monitors hooked up in parallel, plus 1 digital eye piece that projects stats onto my eye. There's only one drink I know, and that's Jolt. Right after I'm finished hacking for the day, I read this and then fall asleep knowing I'm probably the most elite hacker on Earth, totally unstoppable:

This is our world now... the world of the electron and the switch, the beauty of the baud. We make use of a service already existing without paying for what could be dirt-cheap if it wasn't run by profiteering gluttons, and you call us criminals. We explore... and you call us criminals. We seek after knowledge... and you call us criminals. We exist without skin color, without nationality, without religious bias... and you call us criminals. You build atomic bombs, you wage wars, you murder, cheat, and lie to us and try to make us believe it's for our own good, yet we're the criminals.
" | sudo tee /var/www/html/text_files/flag.txt

echo "Linux Genuine Advantage is an exciting and mandatory new way for you to place your computer under the remote control of an untrusted third party!

According to an independent study conducted by some scientists, many users of Linux are running non-Genuine versions of their operating system. This puts them at the disadvantage of having their computers work normally, without periodically phoning home unannounced to see if it's OK for their computer to continue functioning. These users are also missing out on the Advantage of paying ongoing licensing fees to ensure their computer keeps operating properly.

Linux Genuine Advantage works by checking our licensing server periodically to make sure that the copy of Linux you are running is Genuine. This is determined by whether you have paid us the appropriate licensing fees. If you are out of compliance, and are past the grace period, logins to your machine will be disabled until the license fees are paid. How to log in to enter the license key when logins are disabled is left as an exercise for the reader.

Finally! Linux users can experience a feature that until now remained the exclusive domain of proprietary software.
" | sudo tee /var/www/html/text_files/galf.txt

echo <iframe width="560" height="315" src="https://www.youtube.com/watch?v=xvFZjo5PgG0" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe> | sudo tee /var/www/html/videos/flag?.html

echo <iframe width="560" height="315" src="https://www.youtube.com/watch?v=PmD6ONQqi9Y" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe> | sudo tee /var/www/html/videos/FLAGGG?!.html

```

Step 6: Configure the Firewall
Enable UFW and Expose MySQL Port
```bash
sudo ufw enable
sudo ufw allow 3306/tcp     # Allow MySQL port
```
Restrict Other Services
```bash
sudo ufw allow 80/tcp       # Allow HTTP
sudo ufw deny 443/tcp       # Block HTTPS
sudo ufw default deny incoming  # Deny all other incoming traffic
```
Check UFW Status
```bash
sudo ufw status
```
Restart UFW to Apply Changes
```bash
sudo ufw reload
```

Step 7: Restart Services and Test Challenge
```bash
sudo systemctl restart apache2
sudo systemctl status apache2
```

Open a web browser and navigate to http://localhost/login.php

Username: KingCeo or Ted Smith
Password: SigmaWolf123 or Hacked123
After logging in with KingCeo or Ted Smith, the user will be redirected to the index.html page.

Try SQL Injection (for admin user)
Username: admin
Password: password123
After logging in as admin, the real flag will be displayed.

Verify Database Exposure
You can verify that port 3306 (MySQL) is exposed by using nmap

Step 9: Verify Challenge Completion
Log in as admin to view the real flag: 402acb1c3e3f37da6e1bb6cacadc315d.
Test SQL injection with admin' OR '1'='1 to access the admin account.
Check the fake flags to ensure they are working as decoys
