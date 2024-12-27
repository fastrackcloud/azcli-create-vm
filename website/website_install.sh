# This script will work after create_vm.sh is run
# This script has dependencies on variables declared in create_vm.sh

# Part-1
# Get the Public IP of the VM created
pip=$(az network public-ip show \
--resource-group $vm_resourcegroup \
--name $vm_pip --query "ipAddress" \
--output tsv | tr -d '[:space:]')

# Connect to the VM using SSHPASS and install Apache, Git
# Then download the websit code from GitHub andexecute the code
sshpass -p $vm_adminpassword ssh -o StrictHostKeyChecking=no $vm_adminusername@$pip << EOF
sudo apt-get update
sudo apt-get install apache2 php git -y
sudo systemctl enable apache2
sudo systemctl start apache2
sudo git clone https://github.com/fastrackcloud/website-automation.git
sudo cp ./website-automation/* /var/www/html
sudo mv /var/www/html/htaccess /var/www/html/.htaccess
sudo sed -i '19iDirectoryIndex index.php /html/index.php' /etc/apache2/sites-available/000-default.conf 
sudo systemctl restart apache2
EOF
echo "Website is deployed. Visit http://$pip to view the website."

