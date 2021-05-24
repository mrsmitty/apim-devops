#!/bin/bash

# The following Environment Variables are required
#
# DEST_APIM: APIM Deployment Target resource name
# API_NAME: API Name
# RESOURCE_GROUP: Storage Account Resource Group
# TEMPLATE_DIRECTORY: API ARM Template path
#
# TODO: separate storage and apim resource groups


container="templatedeployment"
storageAccount="pwssydstacicd"

echo "Destination APIM: $DEST_APIM"
echo "Destination API: $API_NAME"
echo "Destination Resource Group: $RESOURCE_GROUP"
echo "API Template Director: $TEMPLATE_DIRECTORY"
echo "Linked template Storage Account & Container: $storageAccount/$container"
echo "Build ID: $BUILD_ID"

if [[ ! -z $BUILD_ID ]]; then pathname="$API_NAME-$BUILD_ID"; else pathname="$API_NAME-$EPOCHSECONDS"; fi

echo "Template Dest Path: $pathname"

echo "**UPLOAD**"
echo "Connection String"
connection=$(az storage account show-connection-string \
    --resource-group $RESOURCE_GROUP \
    --name $storageAccount \
    --query connectionString)

echo "Batch Upload"
output=$(az storage blob upload-batch \
    --destination $container \
    --source "$TEMPLATE_DIRECTORY/" \
    --destination-path $pathname \
    --connection-string $connection)

rootFileUri="https://$storageAccount.blob.core.windows.net/$container/$pathname"

echo "**DEPLOYMENT**"

end=`date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ'`
sas=`az storage container generate-sas -n $container --https-only --permissions dlrw --expiry $end --connection-string $connection -o tsv`

INCLUDEPRODUCTS=false
[[ -f $TEMPLATE_DIRECTORY/$API_NAME-products.template.json ]] && $INCLUDEPRODUCTS=true

az deployment group create \
  --name pathname \
  --resource-group $RESOURCE_GROUP \
  --template-uri "$rootFileUri/api-master-template.json" \
  --query-string $sas \
  --parameters @$TEMPLATE_DIRECTORY/$API_NAME-parameters.json \
  --parameters "PolicyXMLBaseUrl=$rootFileUri/policies" \
  --parameters "sasToken=$sas" \
  --parameters "LinkedTemplatesBaseUrl=dummy" \
  --parameters "ApimServiceName=$DEST_APIM" \
  --parameters "includeProducts=$INCLUDEPRODUCTS"