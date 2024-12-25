#!/bin/bash

# Set variables
SUBSCRIPTION_ID="your-subscription-id"
SP_NAME="jenkins-sp"

# Create Service Principal and parse the output
SP_OUTPUT=$(az ad sp create-for-rbac --name "$SP_NAME" --role contributor \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" --sdk-auth)

# Parse JSON output to extract credentials
CLIENT_ID=$(echo "$SP_OUTPUT" | jq -r '.clientId')
CLIENT_SECRET=$(echo "$SP_OUTPUT" | jq -r '.clientSecret')
TENANT_ID=$(echo "$SP_OUTPUT" | jq -r '.tenantId')

# Login to Azure using the Service Principal
echo "Logging in with Service Principal..."
az login --service-principal --username "$CLIENT_ID" --password "$CLIENT_SECRET" --tenant "$TENANT_ID"

