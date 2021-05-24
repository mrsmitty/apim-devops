#!/bin/bash

export DEST_APIM="PWS-SYD-DEV-ARG-CICD"
export API_NAME="PetStoreV3"
export RESOURCE_GROUP="PWS-SYD-ARG-CICD"
export SOURCE_APIM="PWS-SYD-APIM-CICD"
export TEMPLATE_DIRECTORY="/workspaces/apim-devops/api/PetStoreV3"

source apim-template-extract.sh