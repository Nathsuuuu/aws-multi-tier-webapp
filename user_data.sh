#!/bin/bash
sudo apt update -y
sudo apt install -y apache2
sudo systemctl enable apache2
echo "<h1>Hello from Nathan's AWS Web Server</h1>" | sudo tee /var/www/html/index.html
