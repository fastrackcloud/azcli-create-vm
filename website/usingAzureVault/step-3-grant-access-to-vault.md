# Step 3: Grant Managed Identity Access to Key Vault
```bash
#!/bin/bash

# Step 1: Define Variables
keyVaultName="Vault122820241605"    # Name of the Key Vault
vmName="www"                       # Name of the VM

# Step 2: Get the Managed Identity of the VM
vmIdentity=$(az vm show \
  --name $vmName \
  --resource-group $vmResourceGroup \
  --query "identity.principalId" \
  --output tsv)

# Step 3: Grant Access to the Managed Identity
az keyvault set-policy \
  --name $keyVaultName \
  --object-id $vmIdentity \
  --secret-permissions get
