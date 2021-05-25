#!/bin/bash

# The following Environment Variables are required
#
# APIM_NAME: APIM Deployment Target resource name
# APIM_RESOURCE_GROUP: APIM Resource Group
# API_NAME: API Name
# LOCAL_TEMPLATE_DIRECTORY: API ARM Template path
# STORAGE_ACCOUNT, STORAGE_RESOURCE_GROUP, CONTAINER: Storage account 



container="templatedeployment"

# APIM Variables
echo "Destination APIM: $APIM_NAME"
echo "Destination Resource Group: $APIM_RESOURCE_GROUP"
echo "Destination API: $API_NAME"

# Storage Account
ROOT_FILE_URL="https://$STORAGE_ACCOUNT.blob.core.windows.net/$CONTAINER/$REMOTE_TEMPLATE_PATH"
echo "API Template Directory: $LOCAL_TEMPLATE_DIRECTORY"
echo "Remote Template URL: $ROOT_FILE_URL"

IF [[ $UPLOAD_FILES ]]
then
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
fi


echo "**DEPLOYMENT**"

END=`date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ'`
SAS=`az storage container generate-sas -n $CONTAINER --https-only --permissions dlrw --expiry $END --connection-string $CONNECTION -o tsv`

INCLUDEPRODUCTS=false
[[ -f $LOCAL_TEMPLATE_DIRECTORY/$API_NAME-products.template.json ]] && $INCLUDEPRODUCTS=true

az deployment group create \
  --resource-group $APIM_RESOURCE_GROUP \
  --template-uri "$ROOT_FILE_URL/api-master-template.json" \
  --query-string $SAS \
  --parameters @$LOCAL_TEMPLATE_DIRECTORY/$API_NAME-parameters.json \
  --parameters "PolicyXMLBaseUrl=$ROOT_FILE_URL/policies" \
  --parameters "sasToken=$SAS" \
  --parameters "LinkedTemplatesBaseUrl=dummy" \
  --parameters "ApimServiceName=$APIM_NAME" \
  --parameters "includeProducts=$INCLUDEPRODUCTS"
