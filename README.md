# Azure Dev Box Sample

This provides Azure Bicep templates to create Azure Dev Box within your subscription.

## Acknowledgement

- This templates create minimum number of resources on Azure.
- If you need more comprehensive example, find [this repository](https://github.com/Azure-Samples/Devcenter) instead.

## Prerequisites

- Azure Subscription: [Get free subscription](https://azure.microsoft.com/free)
- Azure Developer CLI: [Install](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
- Azure CLI: [Install](https://learn.microsoft.com/cli/azure/install-azure-cli)

## Getting Started

1. Fork this repository to your GitHub account.
1. Set the environment name.

   ```bash
   # PowerShell
   $AZURE_ENV_NAME="dbox$(Get-Random -Max 9999)"

   # Bash
   AZURE_ENV_NAME="dbox$RANDOM"
   ```

1. Set the user principal name (UPN). It typically looks like `alias@domain`.

   > Make sure the UPN MUST be within the tenant. External account or Microsoft Account is not allowed.

   ```bash
   # PowerShell
   $upn="{USER_PRINCIPAL_NAME}"

   # Bash
   upn="{USER_PRINCIPAL_NAME}"
   ```

1. Run the commands in the following order to provision resources.

   ```bash
   azd auth login
   azd init -e $AZURE_ENV_NAME
   azd env set PROJECT_USER_IDS $(az ad user show --id $upn --query "id" -o tsv)
   azd env set PROJECT_ADMIN_IDS $(az ad user show --id $upn --query "id" -o tsv)
   azd up
   ```

1. Once all provisioned, log into [Microsoft Developer Portal](https://devportal.microsoft.com).
1. Create a new Dev Box to use.
1. Once the Dev Box is running, log into the Dev Box with your account.
