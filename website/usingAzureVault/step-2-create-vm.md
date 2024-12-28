# Step 2: Create the VM with Managed Identity
```bash
#!/bin/bash

# Step 1: Define Variables for the VM
vmName="www"                          # Name of the VM
adminUsername="azureuser"             # Admin username for the VM
adminPassword="123456789aA#"          # Replace with a secure password
vnetName="wwwVNet"                    # Virtual Network name
vnetAddressPrefix="10.0.0.0/16"       # Address prefix for VNet
subnetName="wwwSubnet"                # Subnet name
subnetPrefix="10.0.0.0/24"            # Subnet prefix
nsgName="wwwNSG"                      # Network Security Group name
ipName="wwwPublicIP"                  # Public IP name
nicName="wwwNic"                      # Network Interface Card name
osDiskName="wwwOSDisk"                # OS Disk name
location="eastus"                     # Azure location

# Step 2: Create Virtual Network and Subnet
az network vnet create \
  --resource-group $vmResourceGroup \
  --name $vnetName \
  --address-prefix $vnetAddressPrefix \
  --subnet-name $subnetName \
  --subnet-prefix $subnetPrefix

# Step 3: Create Network Security Group and Rules
az network nsg create --resource-group $vmResourceGroup --name $nsgName

# Allow SSH (Port 22)
az network nsg rule create \
  --resource-group $vmResourceGroup \
  --nsg-name $nsgName \
  --name AllowSSH \
  --priority 1000 \
  --protocol Tcp \
  --direction Inbound \
  --destination-port-ranges 22 \
  --access Allow

# Allow HTTP (Port 80)
az network nsg rule create \
  --resource-group $vmResourceGroup \
  --nsg-name $nsgName \
  --name AllowHTTP \
  --priority 1100 \
  --protocol Tcp \
  --direction Inbound \
  --destination-port-ranges 80 \
  --access Allow

# Step 4: Create a Static Public IP
az network public-ip create \
  --resource-group $vmResourceGroup \
  --name $ipName \
  --allocation-method Static

# Step 5: Create Network Interface and Associate NSG and Public IP
az network nic create \
  --resource-group $vmResourceGroup \
  --name $nicName \
  --vnet-name $vnetName \
  --subnet $subnetName \
  --network-security-group $nsgName \
  --public-ip-address $ipName

# Step 6: Create the VM with Basic Cloud-Init
cat <<EOF > cloud-init-basic.txt
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
EOF

az vm create \
  --resource-group $vmResourceGroup \
  --name $vmName \
  --nics $nicName \
  --image UbuntuLTS \
  --size Standard_B1s \
  --admin-username $adminUsername \
  --admin-password $adminPassword \
  --custom-data cloud-init-basic.txt \
  --os-disk-name $osDiskName \
  --authentication-type password \
  --os-disk-size-gb 30
# Step 7: Enable Managed Identity for the VM
az vm identity assign \
  --resource-group $vmResourceGroup \
  --name $vmName
