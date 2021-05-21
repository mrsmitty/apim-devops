#!/bin/bash

SOURCEAPIM="PWS-SYD-APIM-CICD"
RESOURCEGROUP="PWS-SYD-ARG-CICD"
APINAME="PetStoreV3"
DESTAPIM="PWS-SYD-DEV-ARG-CICD"
OUTDIR="/workspaces/apim-devops/api/PetStorev3"
echo "run script"
source apim-devops-tool.sh $SOURCEAPIM $RESOURCEGROUP $APINAME $DESTAPIM $OUTDIR