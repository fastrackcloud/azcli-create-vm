#!/bin/bash

# Variables
resourceGroup="MyResourceGroup"
location="eastus"

# Create Resource Group
az group create --name $resourceGroup --location $location

echo "Resource Group '$resourceGroup' created in location '$location'."

# Variables
resourceGroup="MyResourceGroup"
vnetName="MyVNet"
subnetName="MySubnet"

# Create Virtual Network and Subnet
az network vnet create \
  --resource-group $resourceGroup \
  --name $vnetName \
  --address-prefix "10.0.0.0/16" \
  --subnet-name $subnetName \
  --subnet-prefix "10.0.0.0/24"

echo "Virtual Network '$vnetName' with Subnet '$subnetName' created."

# Variables
resourceGroup="MyResourceGroup"
nsgName="MyNSG"

# Create Network Security Group
az network nsg create \
  --resource-group $resourceGroup \
  --name $nsgName

echo "Network Security Group '$nsgName' created."

# Variables
resourceGroup="MyResourceGroup"
nsgName="MyNSG"

# Add NSG Rules for SSH, HTTP, and HTTPS
az network nsg rule create \
  --resource-group $resourceGroup \
  --nsg-name $nsgName \
  --name AllowSSH \
  --priority 1000 \
  --protocol Tcp \
  --direction Inbound \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 22 \
  --access Allow

az network nsg rule create \
  --resource-group $resourceGroup \
  --nsg-name $nsgName \
  --name AllowHTTP \
  --priority 1100 \
  --protocol Tcp \
  --direction Inbound \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 80 \
  --access Allow

az network nsg rule create \
  --resource-group $resourceGroup \
  --nsg-name $nsgName \
  --name AllowHTTPS \
  --priority 1200 \
  --protocol Tcp \
  --direction Inbound \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 443 \
  --access Allow

echo "NSG rules for SSH, HTTP, and HTTPS created in '$nsgName'."

# Variables
resourceGroup="MyResourceGroup"
ipName="MyPublicIP"

# Create a Static Public IP
az network public-ip create \
  --resource-group $resourceGroup \
  --name $ipName \
  --allocation-method Static

echo "Static Public IP '$ipName' created."

# Variables
resourceGroup="MyResourceGroup"
vnetName="MyVNet"
subnetName="MySubnet"
nsgName="MyNSG"
ipName="MyPublicIP"
nicName="MyNic"

# Create Network Interface with NSG and Public IP
az network nic create \
  --resource-group $resourceGroup \
  --name $nicName \
  --vnet-name $vnetName \
  --subnet $subnetName \
  --network-security-group $nsgName \
  --public-ip-address $ipName

echo "Network Interface \
'$nicName' created with NSG \
'$nsgName' and Public IP '$ipName'."

# Variables
resourceGroup="MyResourceGroup"
vmName="MyVM"
nicName="MyNic"
osDiskName="MyOSDisk"
adminUsername="azureuser"
adminPassword="123456789aA#"  # Replace with a secure password

# Create the VM
az vm create \
  --resource-group $resourceGroup \
  --name $vmName \
  --nics $nicName \
  --image canonical:ubuntu-24_04-lts:server:24.04.202411030 \
  --size Standard_B1s \
  --os-disk-name $osDiskName \
  --admin-username $adminUsername \
  --admin-password $adminPassword \
  --storage-sku Standard_LRS \
  --authentication-type password \
  --os-disk-size-gb 30

export vm_pip=$ipName
export vm_resourcegroup=$resourceGroup
export vm_adminpassword=$adminPassword
export vm_adminusername=$adminUsername

echo "Virtual Machine '$vmName' created."
