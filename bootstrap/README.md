# Bootstrap
This directory contains a one-time Terraform configuration used to create the Azure resources required to store all
Terraform state files for the project and run GHA workflows.

## Prerequisites
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

## How to run
```bash
terraform init
terraform apply
```

Terraform will create the resource group and storage account, then print outputs with the backend configuration details.
Use these values to configure the backend in all other Terraform modules and workflows.

## Cleanup
Do not destroy these resources unless you intend to reset all Terraform states.
If needed, remove the management lock first in the Azure Portal or with:
```bash
az lock delete --name lock-tfstate --resource-group rg-mono-tfstate
az group delete --name rg-mono-tfstate --yes
```
