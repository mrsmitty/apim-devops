#!/bin/bash

# Storage Account
ROOT_FILE_URL="https://$STORAGE_ACCOUNT.blob.core.windows.net/$CONTAINER/$REMOTE_TEMPLATE_PATH"
echo "API Template Directory: $LOCAL_TEMPLATE_DIRECTORY"
echo "Remote Template URL: $ROOT_FILE_URL"

echo "**UPLOAD**"
echo "Connection String"
CONNECTION=$(az storage account show-connection-string \
    --resource-group $STORAGE_RESOURCE_GROUP \
    --name $STORAGE_ACCOUNT \
    --query connectionString)

echo "Batch Upload"
output=$(az storage blob upload-batch \
    --destination $CONTAINER \
    --source "$LOCAL_TEMPLATE_DIRECTORY/" \
    --destination-path $REMOTE_TEMPLATE_PATH \
    --connection-string $CONNECTION)
