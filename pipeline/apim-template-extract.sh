#!/bin/bash

storageAccount="pwssydstacicd"
echo "Source APIM: $SOURCE_APIM"
echo "Destination APIM: $DEST_APIM"
echo "Destination API: $API_NAME"
echo "Destination Resource Group: $RESOURCE_GROUP"
echo "API Template Directory: $TEMPLATE_DIRECTORY"
echo %BUILD_SOURCEBRANCH%

MASTERTEMPLATE="api-master-template.json"

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [[ %BUILD_SOURCEBRANCH% == "master" ]]; then
  echo 'Aborting: cannot run from master branch. Create a new branch before running pipeline.'
  exit 1
fi

if [[ ! -d $TEMPLATE_DIRECTORY ]]
then
    echo "**Create Template Directory**"
    mkdir -p $TEMPLATE_DIRECTORY
    
fi

if [[ ! -f $TEMPLATE_DIRECTORY/api-master-template.json ]]
then
    echo "**Master Template Update**"
    echo "- Copy master template"
    cp ../base-template/master.template.json "$TEMPLATE_DIRECTORY/$MASTERTEMPLATE"
    echo "- Template API Name update"
    sed -i "s/<API_NAME>/$API_NAME/g" "$TEMPLATE_DIRECTORY/$MASTERTEMPLATE"
fi

echo "**Tool Download**"
TOOLURL="https://github.com/Azure/azure-api-management-devops-resource-kit/releases/download/v0.5/Portable.zip"
wget -O "reskit-linux64.zip" $TOOLURL
unzip -o -d reskit reskit-linux64.zip

echo "**Template Extract**"
dotnet ./reskit/Portable/apimtemplate.dll extract \
    --sourceApimName "$SOURCE_APIM" \
    --resourceGroup "$RESOURCE_GROUP" \
    --fileFolder "$TEMPLATE_DIRECTORY" \
    --baseFileName "$API_NAME" \
    --destinationApimName "$DEST_APIM" \
    --policyXMLBaseUrl "https://dummy.blob.core.windows.net/" \
    --apiName "$API_NAME" \
    --paramServiceUrl=true --paramNamedValue=true

echo "**Policy File Reference Update**"
APITEMPLATEPATH=$TEMPLATE_DIRECTORY/$API_NAME-$API_NAME-api.template.json
echo "- Create parameter"
JSON=$(cat $APITEMPLATEPATH | jq '.parameters += {"sasToken":{"type":"string"}}')
echo "- Reference parameter"
JSON=$(sed "s/apiPolicy.xml'/apiPolicy.xml?', parameters('sasToken')/" <<< $JSON)
echo "- Replace file"
echo $JSON | jq '.' > $APITEMPLATEPATH

echo "**Commit Changes**"
changes=$(git diff-index HEAD)
if [[ ! -z $changes ]]; 
then
    git switch -c origin/%BUILD_SOURCEBRANCH%
    echo "- config user"
    git config user.email "apim@devops.com"
    git config user.name "APIM Automation"
    echo "- add and commit"
    git add .
    git commit -m "Extract Tool $API_NAME"
    echo "- push"
    git push
fi

echo "**Clean-up**"
rm -f -r reskit
rm -f reskit-linux64.zip

