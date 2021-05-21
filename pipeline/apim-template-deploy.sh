#!/bin/bash

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
    --source "../api/$APINAME/" \
    --destination-path $pathname \
    --connection-string $connection)

rootFileUri="https://$storageAccount.blob.core.windows.net/$container/$pathname"

echo "DEPLOYMENT"

end=`date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ'`
sas=`az storage container generate-sas -n $container --https-only --permissions dlrw --expiry $end --connection-string $connection -o tsv`

INCLUDEPRODUCTS=false
if [[ -f $APINAME-products.template.json ]]
then
    $INCLUDEPRODUCTS=true
fi

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