#!/bin/bash

SOURCEAPIM=$1
RESOURCEGROUP=$2
APINAME=$3
DESTAPIM=$4

if [[ -d $5 ]]
then
    STAGINGDIR=$5
else
    exit 1
fi

# Download tools
TOOLURL="https://github.com/Azure/azure-api-management-devops-resource-kit/releases/download/v0.5/Portable.zip"
wget -O "reskit-linux64.zip" $TOOLURL
unzip -d reskit reskit-linux64.zip

dotnet ./reskit/Portable/apimtemplate.dll extract \
    --sourceApimName $SOURCEAPIM \
    --resourceGroup $RESOURCEGROUP \
    --fileFolder $STAGINGDIR \
    --apiName $APINAME \
    --destinationApimName $DESTAPIM \
    --paramServiceUrl=true --paramNamedValue=true

