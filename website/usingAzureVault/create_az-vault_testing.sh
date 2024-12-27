#!/bin/bash

# Variables
resourceGroup="CyberSecResourceGroup"
location="eastus"
keyVaultName="MyKeyVault"
secretName="GitHubToken"
secretValue="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"  # Replace with your GitHub token
devOpsVmName="MyVM"
devOpsResourceGroup="DevOpsResourceGroup"

# Step 1: Create a Resource Group for Key Vault (if not already created)
az group create --name $resourceGroup --location $location

# Step 2: Create Key Vault
az keyvault create \
  --name $keyVaultName \
  --resource-group $resourceGroup \
  --location $location

echo "Key Vault '$keyVaultName' created in Resource Group '$resourceGroup'."

# Step 3: Add the GitHub Token as a Secret
az keyvault secret set \
  --vault-name $keyVaultName \
  --name $secretName \
  --value $secretValue

echo "Secret '$secretName' added to Key Vault '$keyVaultName'."

# Step 4: Grant Access to the DevOps VM Managed Identity
# Get the Managed Identity of the DevOps VM
vmIdentity=$(az vm show \
  --name $devOpsVmName \
  --resource-group $devOpsResourceGroup \
  --query "identity.principalId" \
  --output tsv)

if [ -z "$vmIdentity" ]; then
  echo "Error: Managed Identity not found for VM '$devOpsVmName'. Ensure the VM has a Managed Identity enabled."
  exit 1
fi

# Set Access Policy for the Managed Identity
az keyvault set-policy \
  --name $keyVaultName \
  --object-id $vmIdentity \
  --secret-permissions get

echo "Access policy granted for VM Managed Identity on Key Vault '$keyVaultName'."
