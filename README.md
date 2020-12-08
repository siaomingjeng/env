
## Azure Locations of Extension:
- Log: /var/log/azure/custom-script/handler.log
- Script Output: /var/lib/waagent/custom-script/download/0/

## Azure CLI:
- az group create --name \<rg name\> --location \<location\>
- az group deployment create -g \<rg name\> --template-file \<ARM template\> --parameters @\<file\> --query properties.outputs

## Functionalitiy:
- minikube_env.sh: create a testing minikbue env
- ansible_install8.sh: install Ansible in CentOS 8
- env-k8s.sh: prepare an environment for Kubernetes/AKS use
- diff: compare text files
