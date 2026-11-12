Disclaimer: AI was used to generate this file.

# Homelab Infrastructure

The goal for this repository is to put most of my homelab configuration into Terraform and Ansible to make it easy to rebuild should I ever have to. This repo should never expose the names of any Azure resources, nor should it ever expose any secrets or sensitive values. Any resources should be locked down as much as possible (within reason), whilst ensuring cost efficiency remains a priority. This repository is not representitive of an enterprise environment, nor is it how I would configure an enterprise environment; but as I don't have enterprise money I have to get creative to balance both security and cost simultaneously 😅

## Roadmap
- Provision remote state and an azure key vault to retrieve secrets at runtime [✅]
- Create a terraform modules repository to enable remote module storage including versioning of modules [✅]
- Get all virtual machines into Terraform [✅]
- Make this deployable via GitHub actions using CI/CD pipelines [✅]
- Provision scripts to backup configuration for switches, firewalls, access points etc [✅]
- Provision a VM with a cron job that goes away and grabs those backups every x amount of time, saves them to my NAS and remote storage of some kind [✅]
- Get a personal website up and running in Azure with CI/CD pipelines for this []

## Overview

This repository provisions a homelab infrastructure using:

- Azure Resource Manager (`azurerm`) for cloud state backend, resource group, management lock, and Key Vault.
- Proxmox provider (`bpg/proxmox`) for creating and managing VMs on a Proxmox VE host.
- Remote Terraform modules from `https://github.com/mitchellmooreuk/terraform-modules`, pinned to release tags.

## Architecture

- `Azure/` holds the control plane: `main.tf` defines providers, the Azure resource group, management lock and a role assignment, and `app.tf` instantiates the Key Vault module.
- `Hypervisors/terraform/` holds the Proxmox VMs. `app.tf` instantiates the image download and VM modules, and `variables.tf` defines the image and VM settings.
- `Hypervisors/terraform/HVA01.tfvars` and `HVA02.tfvars` hold the settings for each Proxmox host. Each host has its own state.
- Each folder has a `terraform-plan.ps1` that fetches secrets from Azure Key Vault and runs `terraform init` + `terraform plan`. It also adds your current IP to the storage account and Key Vault firewalls.

## Prerequisites

- Terraform `>= 1.5.0`
- PowerShell 7 (`pwsh`) and Azure CLI
- Azure account access and permission to read Key Vault secrets
- A Proxmox API token for each host, stored in Key Vault
- The Terraform SSH key at `~/.ssh/id_rsa_terraform`, used by the Proxmox provider and added to new VMs
- HTTPS access to `https://github.com/mitchellmooreuk/terraform-modules`

## Usage

1. Authenticate to Azure:

```bash
az login
```

2. Confirm the Key Vault secrets are available to `terraform-plan.ps1`.

3. Run the plan script from the folder you're deploying. The parameter values can be found in 1Pass for running this locally.

```powershell
# Hypervisors/terraform, for one host (HVA01 or HVA02)
./terraform-plan.ps1 -nodeName HVA02 -keyVaultName <name> -resourceGroupName <name> -storageAccountName <name>

# Azure
./terraform-plan.ps1 -keyVaultName <name> -resourceGroupName <name> -storageAccountName <name>
```

4. Apply the generated plan:

```bash
terraform apply tfplan
```

## Configuration

- `HVA01.tfvars` and `HVA02.tfvars` contain each host's `pve_endpoint`, image downloads and VM definitions.
- Sensitive values such as `pve_api_token` and `tenant_id` are retrieved from Azure Key Vault by `terraform-plan.ps1`.

## Backend and state

This repository uses an Azure Storage backend configured dynamically by `terraform-plan.ps1`.

The scripts read backend configuration values from Azure Key Vault secrets:

- `backend-container-name`
- `backend-state-key-<name>`, where `<name>` is `azure` or the Proxmox host name

## Notes

- `azurerm_management_lock.homelab` protects the Azure resource group from accidental deletion.
- The `key_vault` role assignment applies the `Key Vault Secrets Officer` role to a fixed principal ID (Entra ID Security Group).
- All resources are tagged correctly

## License

This repository does not include an explicit license. Add one if you intend to share or publish this configuration.
