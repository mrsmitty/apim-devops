#!/bin/bash

# The following Environment Variables are required
#
# DESTAPIM: APIM Deployment Target resource name
# APINAME: API Name
# RESOURCEGROUP: Storage Account Resource Group
# TEMPLATEDIRECTORY: API ARM Template path
#
# TODO: separate storage and apim resource groups

echo "$DESTAPIM"
echo "$APINAME"
echo "$RESOURCEGROUP"
echo "$TEMPLATEDIRECTORY"

pathname="$APINAME-$EPOCHSECONDS"
container="templatedeployment"
storageAccount="pwssydstacicd"


echo "UPLOAD"
connection=$(az storage account show-connection-string \
    --resource-group $RESOURCEGROUP \
    --name $storageAccount \
    --query connectionString)

output=$(az storage blob upload-batch \
    --destination $container \
    --source "$TEMPLATEDIRECTORY/$APINAME/" \
    --destination-path $pathname \
    --connection-string $connection)

rootFileUri="https://$storageAccount.blob.core.windows.net/$container/$pathname"

echo "DEPLOYMENT"

end=`date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ'`
sas=`az storage container generate-sas -n $container --https-only --permissions dlrw --expiry $end --connection-string $connection -o tsv`

INCLUDEPRODUCTS=false
[[ -f $TEMPLATEDIRECTORY/$APINAME/$APINAME-products.template.json ]] && $INCLUDEPRODUCTS=true

az deployment group create \
  --name pathname \
  --resource-group $RESOURCEGROUP \
  --template-uri "$rootFileUri/api-master-template.json" \
  --query-string $sas \
  --parameters @$TEMPLATEDIRECTORY/$APINAME-parameters.json \
  --parameters "PolicyXMLBaseUrl=$rootFileUri/policies" \
  --parameters "sasToken=$sas" \
  --parameters "LinkedTemplatesBaseUrl=dummy" \
  --parameters "ApimServiceName=$DESTAPIM" \
  --parameters "includeProducts=$INCLUDEPRODUCTS"