#!/bin/bash
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install apache2 -y
sleep 20
sudo apt-get install apache2_utils -y
sleep 20
sudo systemctl enable apache2
sudo systemctl start apache2
sudo ufw allow in "Apache"
sudo apt-get install php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y
sudo systemctl restart apache2
wget -c http://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
sudo mv wordpress/* /var/www/html/
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/ 
