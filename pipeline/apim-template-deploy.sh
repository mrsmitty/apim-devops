#!/bin/bash

pathname="petstore-$EPOCHSECONDS"
container="templatedeployment"
storageAccount="pwssydstacicd"
resourceGroup="PWS-SYD-ARG-CICD"


echo "UPLOAD"
connection=$(az storage account show-connection-string \
    --resource-group $resourceGroup \
    --name $storageAccount \
    --query connectionString)

output=$(az storage blob upload-batch \
    --destination $container \
    --source "../api/petstore/" \
    --destination-path $pathname \
    --connection-string $connection)

rootFileUri="https://$storageAccount.blob.core.windows.net/$container/$pathname"

echo "DEPLOYMENT"

end=`date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ'`
sas=`az storage container generate-sas -n $container --https-only --permissions dlrw --expiry $end --connection-string $connection -o tsv`

az deployment group create \
  --name pathname \
  --resource-group $resourceGroup \
  --template-uri "$rootFileUri/petstore-master.template.json" \
  --query-string $sas \
  --parameters @/workspaces/apim-devops/api/petstore/petstore-parameters.json \
  --parameters "PolicyXMLBaseUrl=$rootFileUri/policies" \
  --parameters "sasToken=$sas"