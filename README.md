# mono-deploy

## Bootstrap
Deployment automation requires Terraform state which cannot be automated due to chicken-and-egg problem. Also,
automation requires service principals which should not be assigned automatically because of security concerns. That is
why starting new automation requires manual steps covered by bootstrap configuration. 

### Prerequisites
1. You must have Azure CLI and Terraform installed. Use tools like Brew.
2. You must be logged in to Azure CLI with an account that has Contributor rights:
```bash
az login
az account set –subscription <SUBSCRIPTION_ID>
```
3. Confirm the correct subscription is selected:
```bash
az account show
```

### How to run
```bash
terraform init
terraform apply
```
Terraform will create the resource group and storage account, then print outputs with the backend configuration details.
Use these values to configure the backend in all other Terraform modules and workflows.

### Cleanup
If needed, remove the management lock first in the Azure Portal or with:
```bash
az lock delete --name lock-devops --resource-group rg-mono-devops
az group delete --name rg-mono-devops --yes
```

### Configuration
1. Update GH secrets (AZURE_SUBSCRIPTION_ID, AZURE_TENANT_ID and AZURE_CLIENT_ID) in mono-deploy.
2. Update GH secrets in all code repos (e.g. mono-jvm). PLEASE NOTE: there is a different CLIENT_ID.
3Update TF backend configuration in mono-deploy.
