sudo git clone https://github.com/fastrackcloud/website-automation.git
sudo cp ./website-automation/* /var/www/html
sudo mv /var/www/html/htaccess /var/www/html/.htaccess
sudo sed -i '19iDirectoryIndex index.php /html/index.php' /etc/apache2/sites-available/000-default.conf 
sudo systemctl restart apache2
