#!/bin/sh

SUBID="71507755-196c-4337-9af0-209898cc3f0b"
RGNAME="PWS-SYD-ARG-CICD"
LOCATION="australiaeast"
az group create -n $RGNAME -l $LOCATION
az deployment group create -f template.json -g $RGNAME