How to Solve the Challenge as a Participant

Step 1: Initial Reconnaissance

Start with Nmap Scans

Use Nmap to identify open ports and services on the target web server.

    ```bash

    nmap -p- <server-ip>
    ```
Identify open ports like HTTP (80), MySQL (3306), and SSH (22).
Explore the Website

Use a web browser to visit the site (e.g., http://<server-ip>/login.php). View the page source for hidden comments or clues.

Directory Enumeration

Use tools like Gobuster or dirb to enumerate directories and hidden files.


    ```bash
    gobuster dir -u http://<server-ip>/ -w /usr/share/wordlists/dirb/common.txt
    ```
    This will help identify paths like /fake_flags/.

Step 2: SQL Injection to Retrieve the Real Flag

    Try Logging In

    Attempt a simple login with random credentials like test/test. It will likely fail, indicating a login form.

    Perform SQL Injection

    Use SQL injection to bypass the login form. Input the following for the username:

    admin' OR '1'='1

    This payload bypasses authentication, and the page will return the real flag, e.g., FLAG{REAL_SQL_INJECTION_FLAG}.

Step 3: Explore Red Herring Flags

While the real flag is already found via SQL injection, participants may want to explore further to find red herring flags:

Use curl/Wget to Inspect Files

Use tools like curl and wget to explore the directories and examine fake flags.

    bash

    curl http://<server-ip>/fake_flags/fake1.txt

Use Exiftool for Image Metadata

Download images and inspect their metadata for hidden fake flags.

    wget http://<server-ip>/fake_flags/fake_image.jpg
    exiftool fake_image.jpg

Step 4: Dealing with the Misconfigured Firewall

  Access MySQL/SSH

  Use open services (e.g., MySQL or SSH) to explore other ways to get information from the server.

  Use SQL to Query the Database

    If they manage to access MySQL via port 3306, they can query the users table directly for the flag.
