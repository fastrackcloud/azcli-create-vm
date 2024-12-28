# Step 2: Apply the Custom Script Extension
az vm extension set \
  --resource-group $vmResourceGroup \
  --vm-name $vmName \
  --name CustomScript \
  --publisher Microsoft.Azure.Extensions \
  --settings '{"fileUris": ["<URL_TO_POST_SETUP_CLOUD_INIT>"], "commandToExecute": "cloud-init apply /path/to/post-setup-cloud-init.txt"}'
