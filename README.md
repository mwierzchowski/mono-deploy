# mono-deploy

Starting (or starting-over) infra provisioning and CD automation require manual setup steps before first executiuon due 
to a chicken-and-egg problem: 
- Terraform requires tfstate for reproductibility which is one-time step only.
- GitHub Actions require service principals to run Terraform.
Additionally, CI automation requires a service principal to be able to push images or artifacts to Azure which 
should not be granted by GitHub actions itself to minimize potential security incident blast radius.   

## Setup

> [!TIP]
> User have to be in the root directory of the repository and logged in to Azure CLI. See [Troubleshooting]
> (#troubleshooting)
> for more details.

### Tfstate

```bash
terraform -chdir=./bootstrap/tfstate init
terraform -chdir=./bootstrap/tfstate apply -auto-approve \
          -var-file=../../terraform.tfvars
```

### GitHub Actions

```bash
terraform -chdir=./bootstrap/github_actions init \
          -backend-config=../../terraform.tfbackend
terraform -chdir=./bootstrap/github_actions apply -auto-approve \
          -var-file=../../terraform.tfvars
```

TODO - trouble shooting
Update github secrets in all repositories.

### Configuration

1. Update GH secrets (AZURE_SUBSCRIPTION_ID, AZURE_TENANT_ID and AZURE_CLIENT_ID) in mono-deploy.
2. Update GH secrets in all code repos (e.g. mono-jvm). PLEASE NOTE: there is a different CLIENT_ID. 3Update TF backend
   configuration in mono-deploy.

## Troubleshooting

### Azure login

```bash
az login
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
export ARM_TENANT_ID=$(az account show --query tenantId -o tsv)
```

### Delete protected RGs

```bash
az lock delete --name tfstate-lock --resource-group rg-mono-tfstate
az lock delete --name devops-lock --resource-group rg-mono-devops
az group delete --name rg-mono-tfstate --yes
az group delete --name rg-mono-devops --yes
```

### Delete Entra apps

Visit Microsoft Entra ID
[App registrations](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/RegisteredApps).

### Terraform backend has changed

In case of changed Terraform backend following entries have to be updated:
1. `terraform.tfbackend`
2. `terraform.tfvars`

