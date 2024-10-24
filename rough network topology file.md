```bash
version: '3.8'

services:
  # Web server hosting the vulnerable login page
  web:
    image: php:7.4-apache
    container_name: web_server
    ports:
      - "80:80"
    volumes:
      - ./web:/var/www/html  # Mount the web directory
    networks:
      - ctf_network
    depends_on:
      - db

  # MySQL database storing user data and the real flag
  db:
    image: mysql:5.7
    container_name: mysql_db
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: ctf_challenge
      MYSQL_USER: ctf_user
      MYSQL_PASSWORD: userpassword
    ports:
      - "3306:3306"
    networks:
      - ctf_network

  # Misconfigured firewall (optional setup)
  firewall:
    image: alpine
    container_name: misconfigured_firewall
    networks:
      - ctf_network
    cap_add:
      - NET_ADMIN
    command: >
      sh -c "iptables -A INPUT -p tcp --dport 80 -j ACCEPT && 
             iptables -A INPUT -p tcp --dport 3306 -j ACCEPT &&
             iptables -A INPUT -p tcp --dport 22 -j ACCEPT &&
             iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT"
    depends_on:
      - web
      - db

networks:
  ctf_network:
    driver: bridge
```
Explanation:

    Web Server (Apache2 + PHP):
        Hosts the vulnerable login page on port 80. The web directory (containing HTML, PHP files, and fake flags) is mounted into /var/www/html.

    MySQL Database:
        Runs on port 3306 and is initialized with a database ctf_challenge, storing the real flag.

    Misconfigured Firewall:
        Uses iptables to simulate a firewall that allows access to the HTTP, MySQL, and SSH ports.

    Network:
        All services (web, db, and firewall) are connected on a single subnet (ctf_network).

Setting Up:

    Place this docker-compose.yml file in your project directory.
    Create a web/ directory to store the login page, red herring flags, and other necessary files for the challenge.
    Run the following command to start the CTF environment:
```bash
docker-compose up -d
```
