
#!/bin/bash

# Variables
resourceGroup="DevOpsResourceGroup"           # Resource Group for the VM
location="eastus"                             # Location for the VM
vmName="MyVM"                                 # Name of the VM
adminUsername="azureuser"                     # Admin username for the VM
adminPassword="123456789aA#"                  # Replace with a secure password
vnetName="DevOpsVNet"                         # Name of the Virtual Network
subnetName="DevOpsSubnet"                     # Name of the Subnet
nsgName="DevOpsNSG"                           # Name of the Network Security Group
ipName="DevOpsPublicIP"                       # Name of the Public IP
nicName="DevOpsNic"                           # Name of the Network Interface
osDiskName="DevOpsOSDisk"                     # Name of the OS Disk
keyVaultName="MyKeyVault"                     # Name of the Key Vault created by the CyberSec team
secretName="GitHubToken"                      # Name of the secret containing the GitHub token

# Step 1: Create a Resource Group for the VM (if not already created)
az group create --name $resourceGroup --location $location

# Step 2: Create Virtual Network and Subnet
az network vnet create \
  --resource-group $resourceGroup \
  --name $vnetName \
  --address-prefix "10.0.0.0/16" \
  --subnet-name $subnetName \
  --subnet-prefix "10.0.0.0/24"

# Step 3: Create Network Security Group with rules for SSH and HTTP
az network nsg create --resource-group $resourceGroup --name $nsgName
az network nsg rule create --resource-group $resourceGroup --nsg-name $nsgName --name AllowSSH --priority 1000 --protocol Tcp --direction Inbound --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 22 --access Allow
az network nsg rule create --resource-group $resourceGroup --nsg-name $nsgName --name AllowHTTP --priority 1100 --protocol Tcp --direction Inbound --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 80 --access Allow

# Step 4: Create a Static Public IP
az network public-ip create --resource-group $resourceGroup --name $ipName --allocation-method Static

# Step 5: Create Network Interface
az network nic create \
  --resource-group $resourceGroup \
  --name $nicName \
  --vnet-name $vnetName \
  --subnet $subnetName \
  --network-security-group $nsgName \
  --public-ip-address $ipName

# Step 6: Enable Managed Identity for the VM
az vm identity assign \
  --resource-group $resourceGroup \
  --name $vmName

# Step 7: Create Cloud-Init Configuration
cat <<EOF > cloud-init.txt
#cloud-config
package_update: true
packages:
  - apache2
  - php
  - git
runcmd:
  - apt-get update
  - apt-get install apache2 php git -y
  - systemctl enable apache2
  - systemctl start apache2
  - TOKEN=\$(az keyvault secret show --name $secretName --vault-name $keyVaultName --query value -o tsv)
  - git clone https://\$TOKEN@github.com/<username>/<repository>.git /tmp/website-automation
  - cp /tmp/website-automation/* /var/www/html/
  - mv /var/www/html/htaccess /var/www/html/.htaccess
  - sed -i '19iDirectoryIndex index.php /html/index.php' /etc/apache2/sites-available/000-default.conf
  - systemctl restart apache2
EOF

# Step 8: Create the VM with Cloud-Init
az vm create \
  --resource-group $resourceGroup \
  --name $vmName \
  --nics $nicName \
  --image canonical:ubuntu-24_04-lts:server:24.04.202411030 \
  --size Standard_B1s \
  --os-disk-name $osDiskName \
  --admin-username $adminUsername \
  --admin-password $adminPassword \
  --custom-data cloud-init.txt \
  --authentication-type password \
  --os-disk-size-gb 30

# Step 9: Output the Public IP Address
publicIP=$(az network public-ip show --resource-group $resourceGroup --name $ipName --query "ipAddress" --output tsv)
echo "VM created and website deployed. Visit http://$publicIP to view the website."
