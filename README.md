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

### Create tfstate backend
```bash
terraform -chdir=./base/tfstate init
terraform -chdir=./base/tfstate apply -auto-approve -var-file=../../terraform.tfvars
```

### Deploy devops stack

```bash
terraform -chdir=./base/devops init -backend-config=../../terraform.tfbackend
terraform -chdir=./base/devops apply -auto-approve -var-file=../../terraform.tfvars
```
Update GH secrets (`AZURE_SUBSCRIPTION_ID`, `AZURE_TENANT_ID` and `AZURE_CLIENT_ID`) in:
1. [mono-deploy](https://github.com/mwierzchowski/mono-deploy/settings/secrets/actions)
2. [mono-jvm](https://github.com/mwierzchowski/mono-jvm/settings/secrets/actions)
3. ... and other code repos

<a name="troubleshooting"></a>
## Troubleshooting

### Mono-deploy PAT has expired
1. Regenerate [`mono-deploy-write`](https://github.com/settings/personal-access-tokens/9082055) PAT.
2. Update [`MONO_DEPLOY_PUSH_TOKEN`](https://github.com/mwierzchowski/mono-jvm/settings/secrets/actions/MONO_DEPLOY_PUSH_TOKEN)
   secret in mono-jvm.
3. ... and in other code repos.

### Azure login
```bash
az login
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
export ARM_TENANT_ID=$(az account show --query tenantId -o tsv)
```

### Delete protected resources
DevOps:
```bash
az lock delete --name devops-st-lock --resource-group rg-mono-devops
az lock delete --name devops-acr-lock --resource-group rg-mono-devops
az group delete --name rg-mono-devops --yes
```
Tfstate:
```bash
az lock delete --name tfstate-lock --resource-group rg-mono-tfstate
az group delete --name rg-mono-tfstate --yes
```

### Terraform backend has changed
Update:
1. `terraform.tfbackend` / `storage_account_name`
2. `terraform.tfvars` / `tfstate.storage`

### DevOps storage and/or ACR have changed
Update:
1. File `terraform.tfvars` / `devops.storage`
2. File `terraform.tfvars` / `devops.registry`
3. GH Variables (`ARTIFACT_CONTAINER`, `ARTIFACT_STORAGE`, `IMAGE_REGISTRY`) in
   [mono-jvm](https://github.com/mwierzchowski/mono-jvm/settings/variables/actions)
4. ... and in other code repos

### Delete Entra apps
Delete app [registrations](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/RegisteredApps)
in  Azure Portal.

### Generate new random suffix
```bash
terraform -chdir=./bootstrap/random_suffix init
terraform -chdir=./bootstrap/random_suffix apply -auto-approve
```
