#!/bin/bash

# Update and upgrade the system
echo "Updating and upgrading the system..."
sudo apt update && sudo apt upgrade -y

# Install Apache, MySQL, and PHP
echo "Installing Apache Web Server..."
sudo apt install -y apache2

echo "Installing MySQL Server..."
sudo apt install -y mysql-server

echo "Installing PHP and required extensions..."
sudo apt install -y php php-mysqli libapache2-mod-php

# Install Firewall and nmap
echo "Installing firewall..."
sudo apt install -y ufw

echo "Installing nmap"
sudo apt install -y nmap

# Restart Apache to apply changes
echo "Restarting Apache..."
sudo systemctl restart apache2

USER="ctf_user"
PASSWORD="pass"
DB="ctf_challenge"

# Configure MySQL Database
echo "Configuring MySQL Database..."
sudo mysql <<EOF
-- Create the database 'ctf_challenge' if it doesn't exist
CREATE DATABASE IF NOT EXISTS $DB;

-- Create the 'ctf_user' user if it doesn't exist and grant privileges
CREATE USER IF NOT EXISTS '$USER'@'localhost' IDENTIFIED BY '$PASSWORD';

-- Grant privileges to 'ctf_user' on the 'ctf_challenge' database
GRANT ALL PRIVILEGES ON $DB.* TO '$USER'@'localhost';

-- Apply the changes
FLUSH PRIVILEGES;

-- Use the 'ctf_challenge' database
USE $DB;

-- Create the 'users' table if it doesn't exist
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    flag VARCHAR(255) DEFAULT NULL
);

-- Insert users into the 'users' table
INSERT INTO users (username, password, flag) 
VALUES 
    ('KingCeo', 'SigmaWolf123', NULL),
    ('Ted Smith', 'Hacked123', NULL),
    ('admin', 'password123', '402acb1c3e3f37da6e1bb6cacadc315d'); -- Real flag hidden under admin

EOF

# Create the vulnerable login page
echo "Creating the vulnerable login page (login.php)..."
sudo bash -c 'cat > /var/www/html/login.php <<EOL
<?php
// Database connection
$host = "localhost";
$db = "ctf_challenge";
$user = "ctf_user";
$pass = "pass";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$flag = ""; // Variable to store the flag

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Ensure input sanitization to avoid SQL injection (important for this example)
    $username = $_POST['username'];
    $password = $_POST['password'];

    / \$query = "SELECT * FROM users WHERE username='\$username' AND password='\$password'";
    \$result = \$conn->query(\$query);


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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Page</title>
</head>
<body>
    <h2>Login</h2>
    <form method="POST" action="">
        Username: <input type="text" name="username" required><br>
        Password: <input type="password" name="password" required><br>
        <input type="submit" value="Login">
    </form>
</body>
</html>

EOL'


echo "Setting file permissions for login.php..."
sudo chown www-data:www-data /var/www/html/login.php
sudo chmod 755 /var/www/html/login.php


# Create the index.html file
echo "Creating the index.html file..."
sudo bash -c 'cat > /var/www/html/index.html <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CTF Challenge</title>
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
EOL'

# Create fake flag files
echo "Creating fake flag files (Red Herrings)..."
sudo mkdir -p /var/www/html/images /var/www/html/text_files /var/www/html/videos

echo "<a href=\"https://raw.githubusercontent.com/Bailey-Hyrne/Networking-AI3/refs/heads/main/goofy1.webp\">Flaig</a>" | sudo tee /var/www/html/images/flag11514.html
echo "Every morning I wake up and I turn on my computer. I put my sunglasses on because the light hurts my eyes. I put on my typing gloves. I connect to the internet web through 8 proxies and then I hack until sundown. I'm probably the best hacker I know; I've hit banks, schools, doctors offices, oil tanks, farms, FedEx, Walmart, KFC, grocery stores. You name it, I probably hacked into it. I even have it set up where I can see the grocery transactions in my term window as they happen. I have 6 monitors hooked up in parallel, plus 1 digital eye piece that projects stats onto my eye. There's only one drink I know, and that's Jolt. Right after I'm finished hacking for the day, I read this and then fall asleep knowing I'm probably the most elite hacker on Earth, totally unstoppable:

This is our world now... the world of the electron and the switch, the beauty of the baud. We make use of a service already existing without paying for what could be dirt-cheap if it wasn't run by profiteering gluttons, and you call us criminals. We explore... and you call us criminals. We seek after knowledge... and you call us criminals. We exist without skin color, without nationality, without religious bias... and you call us criminals. You build atomic bombs, you wage wars, you murder, cheat, and lie to us and try to make us believe it's for our own good, yet we're the criminals." | sudo tee /var/www/html/text_files/flag.txt

echo "Linux Genuine Advantage is an exciting and mandatory new way for you to place your computer under the remote control of an untrusted third party!

According to an independent study conducted by some scientists, many users of Linux are running non-Genuine versions of their operating system. This puts them at the disadvantage of having their computers work normally, without periodically phoning home unannounced to see if it's OK for their computer to continue functioning. These users are also missing out on the Advantage of paying ongoing licensing fees to ensure their computer keeps operating properly.

Linux Genuine Advantage works by checking our licensing server periodically to make sure that the copy of Linux you are running is Genuine. This is determined by whether you have paid us the appropriate licensing fees. If you are out of compliance, and are past the grace period, logins to your machine will be disabled until the license fees are paid. How to log in to enter the license key when logins are disabled is left as an exercise for the reader.

Finally! Linux users can experience a feature that until now remained the exclusive domain of proprietary software." | sudo tee /var/www/html/text_files/galf.txt

echo "<iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/watch?v=xvFZjo5PgG0\" title=\"YouTube video player\" frameborder=\"0\" allowfullscreen></iframe>" | sudo tee /var/www/html/videos/flag?.html

echo "<iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/watch?v=PmD6ONQqi9Y\" title=\"YouTube video player\" frameborder=\"0\" allowfullscreen></iframe>" | sudo tee /var/www/html/videos/FLAGGG?!.html

# Configure UFW firewall
echo "Configuring UFW firewall..."
sudo ufw enable                       # Enable the firewall
sudo ufw allow 3306/tcp               # Allow MySQL connections (for challenge setup)
sudo ufw allow 80/tcp                 # Allow HTTP connections for Apache
sudo ufw deny 443/tcp                 # Block HTTPS (for your testing requirements)
sudo ufw default deny incoming        # Deny all other incoming traffic
sudo ufw reload                       # Reload UFW settings
sudo ufw status                       # Check the firewall status

# Restart Apache to apply changes
echo "Restarting Apache and checking the status..."
sudo systemctl restart apache2
sudo systemctl status apache2

# Output completion message
echo "Setup completed. You can now access the challenge at http://localhost/login.php"
echo "Try logging in with KingCeo or Ted Smith (Username: KingCeo, Password: SigmaWolf123)."
echo "Use SQL injection to access the admin account (Username: admin, Password: ' OR '1'='1)."
