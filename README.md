# Microsoft Dev Box Sample

This provides [Azure Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/overview?WT.mc_id=dotnet-101825-juyoo) templates to create [Microsoft Dev Box](https://learn.microsoft.com/azure/dev-box/overview-what-is-microsoft-dev-box?WT.mc_id=dotnet-101825-juyoo) within your subscription.

## Acknowledgement

- This templates create minimum number of resources on Azure.
- If you need more comprehensive example, find [this repository](https://github.com/Azure-Samples/Devcenter) instead.

## Prerequisites

- Azure Subscription: [Get free subscription](https://azure.microsoft.com/free?WT.mc_id=dotnet-101825-juyoo)
- Azure Developer CLI: [Install](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd?WT.mc_id=dotnet-101825-juyoo)
- Azure CLI: [Install](https://learn.microsoft.com/cli/azure/install-azure-cli?WT.mc_id=dotnet-101825-juyoo)

## Getting Started

1. Fork this repository to your GitHub account.
1. Set the environment name.

   ```bash
   # PowerShell
   $AZURE_ENV_NAME="dbox$(Get-Random -Max 9999)"

   # Bash
   AZURE_ENV_NAME="dbox$RANDOM"
   ```

1. Set the user principal name (UPN) of your tenant. It typically looks like `alias@domain`.

   > Make sure the UPN MUST be within the tenant. External account or Microsoft Account is not allowed.

   ```bash
   # PowerShell
   $upn="{USER_PRINCIPAL_NAME}"

   # Bash
   upn="{USER_PRINCIPAL_NAME}"
   ```

1. Run the commands in the following order to provision resources.

   ```bash
   # Azure CLI
   az login

   # Azure Dev CLI
   azd auth login
   azd init -e $AZURE_ENV_NAME
   azd env set PROJECT_USER_IDS $(az ad user show --id $upn --query "id" -o tsv)
   azd env set PROJECT_ADMIN_IDS $(az ad user show --id $upn --query "id" -o tsv)
   azd up
   ```

1. Once all provisioned, log into [Microsoft Developer Portal](https://devportal.microsoft.com?WT.mc_id=dotnet-101825-juyoo).
1. Create a new Dev Box to use.
1. Once the Dev Box is running, log into the Dev Box with your account.

## Want to try more?

Here are some documents you might be interested in:

- [Microsoft Dev Box &ndash; Announcement](https://azure.microsoft.com/en-us/blog/dev-optimized-cloud-based-workstations-microsoft-dev-box-is-now-generally-available/?WT.mc_id=dotnet-101825-juyoo)
- [What is Microsoft Dev Box?](https://learn.microsoft.com/azure/dev-box/overview-what-is-microsoft-dev-box?WT.mc_id=dotnet-101825-juyoo)
- [Set up Microsoft Dev Box](https://learn.microsoft.com/azure/dev-box/quickstart-configure-dev-box-service?WT.mc_id=dotnet-101825-juyoo)
- [Create a Dev Box from Developer Portal](https://learn.microsoft.com/azure/dev-box/quickstart-create-dev-box?WT.mc_id=dotnet-101825-juyoo)
- [Azure Dev Center Quick Start](https://github.com/Azure-Samples/Devcenter)
