RGNAME="PWS-SYD-ARG-CICD"
LOCATION="australiaeast"
az group create -n $RGNAME -l $LOCATION
az deployment group create -f template.json -g $RGNAME