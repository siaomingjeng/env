
## Azure Locations of Extension:
- Log: /var/log/azure/custom-script/handler.log
- Script Output: /var/lib/waagent/custom-script/download/0/

## Azure CLI:
- az group create --name \<rg name\> --location \<location\>
- az group deployment create -g \<rg name\> --template-file \<ARM template\> --parameters @\<file\> --query properties.outputs
