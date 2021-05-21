#!/bin/bash

SOURCEAPIM=$1
RESOURCEGROUP=$2
APINAME=$3
DESTAPIM=$4
storageAccount="pwssydstacicd"

if [[ -d $5 ]]
then
    STAGINGDIR=$5
else
    echo "Dest dir not found"
    exit 1
fi




# Download tools
TOOLURL="https://github.com/Azure/azure-api-management-devops-resource-kit/releases/download/v0.5/Portable.zip"
wget -O "reskit-linux64.zip" $TOOLURL
unzip -o -d reskit reskit-linux64.zip

rootFileUri="https://dummy.blob.core.windows.net/"

dotnet ./reskit/Portable/apimtemplate.dll extract \
    --sourceApimName $SOURCEAPIM \
    --resourceGroup $RESOURCEGROUP \
    --fileFolder $STAGINGDIR \
    --baseFileName $APINAME \
    --destinationApimName $DESTAPIM \
    --linkedTemplatesBaseUrl $rootFileUri \
    --policyXMLBaseUrl $rootFileUri \
    --apiName $APINAME \
    --paramServiceUrl=true --paramNamedValue=true

    # --splitAPIs "true" \