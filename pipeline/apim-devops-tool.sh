#!/bin/bash

SOURCEAPIM=$1
RESOURCEGROUP=$2
APINAME=$3
DESTAPIM=$4
storageAccount="pwssydstacicd"
STAGINGDIR="/workspaces/apim-devops/api/$APINAME"
MASTERTEMPLATE="api-master-template.json"

if [[ ! -d $STAGINGDIR ]]
then
    echo "creating directory"
    mkdir -p $STAGINGDIR
    
fi

if [[ ! -f $STAGINGDIR/api-master-template.json ]]
then
    echo "copy in master template"
    cp ../base-template/master.template.json "$STAGINGDIR/$MASTERTEMPLATE"
    echo "replace name of api template"
    sed -i "s/<apiname>/$APINAME/g" "$STAGINGDIR/$MASTERTEMPLATE"
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
    --policyXMLBaseUrl $rootFileUri \
    --apiName $APINAME \
    --paramServiceUrl=true --paramNamedValue=true

echo "Enable Policy file reference for SAS Token"
APITEMPLATEPATH=$STAGINGDIR/$APINAME-$APINAME-api.template.json
JSON=$(cat $APITEMPLATEPATH | jq '.parameters += {"sasToken":{"type":"string"}}')
JSON=$(sed "s/apiPolicy.xml'/apiPolicy.xml?', parameters('sasToken')/" <<< $JSON)
echo $JSON | jq '.' > $APITEMPLATEPATH
