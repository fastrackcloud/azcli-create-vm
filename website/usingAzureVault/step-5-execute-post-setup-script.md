# Step 5: Execute Post-Setup Script (Custom Script Extension)
```bash
#!/bin/bash
# Variables
resourceGroup="VMGroup"
vmName="www"
scriptUrl="https://your-storage-account.blob.core.windows.net/scripts/post-setup.sh"  # Replace with your script URL
scriptFile="post-setup.sh"  # Or the local path to your script file

# Step 4: Execute Post-Setup Script using Custom Script Extension
az vm extension set \
  --resource-group $resourceGroup \
  --vm-name $vmName \
  --name customScript \
  --publisher Microsoft.Compute \
  --script $scriptFile  # You can also use --script-uri for a URL

# Alternatively, if using a URL:
az vm extension set \
  --resource-group $resourceGroup \
  --vm-name $vmName \
  --name customScript \
  --publisher Microsoft.Compute \
  --script-uri $scriptUrl
