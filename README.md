# APIM DevOps

CI / CD processes for Azure API Management

Specify an API and APIM instance
Extract API templates
Deploy to another APIM instance

## Execution

```bash
SOURCEAPIM="PWS-SYD-APIM-CICD"
RESOURCEGROUP="PWS-SYD-ARG-CICD"
APINAME="messagingservice"
DESTAPIM="PWS-SYD-DEV-ARG-CICD"
OUTDIR="/workspaces/apim-devops/api/messagingservice"
./apim-devops-tool.sh $SOURCEAPIM $RESOURCEGROUP $APINAME $DESTAPIM $OUTDIR
```

## Pipeline Structure
```
Branch
Extract
Commit
PR
```
## References

- [APIM ARM Template](https://docs.microsoft.com/en-us/azure/templates/microsoft.apimanagement/2019-12-01/service?tabs=json)
- [APIM DevOps Resource Kit](https://github.com/Azure/azure-api-management-devops-resource-kit)
- [APIM RBAC](https://techcommunity.microsoft.com/t5/azure-paas-blog/usage-of-custom-rbac-roles-in-azure-api-management/ba-p/1560571)
- [Deploy Linked Templates with a SAS Token](https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/azure-resource-manager/templates/linked-templates.md)
- [Securing an external template](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/linked-templates?tabs=azure-powershell#securing-an-external-template)