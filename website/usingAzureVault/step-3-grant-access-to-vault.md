# Step 3: Grant Managed Identity Access to Key Vault
```bash
#!/bin/bash

# Step 1: Define Variables
keyVaultName="Vault122820241605"    # Name of the Key Vault
vmName="www"                       # Name of the VM
subscriptionId="0c84006d-562f-4613-bf8e-8c569ab55095"
resourceGroup="VMGroup"

# Step 2: Get the Managed Identity of the VM
vmIdentity=$(az vm show \
  --name $vmName \
  --resource-group $ResourceGroup \
  --query "identity.principalId" \
  --output tsv)

# Step 3: Assign the Key Vault Secrets User role to the VM's Managed Identity
az role assignment create \
  --assignee $vmIdentity \
  --role "Key Vault Secrets User" \
  --scope "/subscriptions/$subscriptionId/resourceGroups/$vmresourceGroup/providers/Microsoft.KeyVault/vaults/$keyVaultName"

