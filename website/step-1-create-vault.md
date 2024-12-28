# Step 1: Create Key Vault and Add the Secret

```bash
#!/bin/bash

# Step 1: Define Variables for Resource Groups
vaultResourceGroup="VaultGroup"  # Resource group for Key Vault
vmResourceGroup="VMGroup"        # Resource group for the VM
location="eastus"                # Azure location

# Step 2: Create Resource Groups
az group create --name $vaultResourceGroup --location $location
az group create --name $vmResourceGroup --location $location

# Step 3: Define Key Vault Variables
keyVaultName="Vault122820241605" # Unique name for the Key Vault
secretName="GitHubToken"         # Name of the secret in Key Vault
secretValue="github_pat_..."     # Replace with your actual GitHub token

# Step 4: Create Key Vault
az keyvault create \
  --name $keyVaultName \
  --resource-group $vaultResourceGroup \
  --location $location

# Step 5: Add the GitHub Token as a Secret in Key Vault
az keyvault secret set \
  --vault-name $keyVaultName \
  --name $secretName \
  --value $secretValue
