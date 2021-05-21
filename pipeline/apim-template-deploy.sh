#!/bin/bash

resourceGroup=$1
apimName=$2
apiname=$3
templatedirectory=$4

pathname="$apiname-$EPOCHSECONDS"
container="templatedeployment"
storageAccount="pwssydstacicd"


echo "UPLOAD"
connection=$(az storage account show-connection-string \
    --resource-group $resourceGroup \
    --name $storageAccount \
    --query connectionString)

output=$(az storage blob upload-batch \
    --destination $container \
    --source "../api/$apiname/" \
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
  --resource-group $resourceGroup \
  --template-uri "$rootFileUri/api-master-template.json" \
  --query-string $sas \
  --parameters @$templatedirectory/$apiname-parameters.json \
  --parameters "PolicyXMLBaseUrl=$rootFileUri/policies" \
  --parameters "sasToken=$sas" \
  --parameters "LinkedTemplatesBaseUrl=dummy" \
  --parameters "ApimServiceName=$apimName" \
  --parameters "includeProducts=$INCLUDEPRODUCTS"