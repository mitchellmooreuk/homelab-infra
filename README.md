# Homelab Infrastructure

Terraform configuration for provisioning a homelab infrastructure with Azure resource management and Proxmox virtual machine lifecycle management.

## Overview

This repository provisions a homelab infrastructure using:

- Azure Resource Manager (`azurerm`) for cloud state backend, resource group, management lock, and Key Vault.
- Proxmox provider (`bpg/proxmox`) for creating and managing VMs on a Proxmox VE host.
- Remote Terraform modules from `git@github.com:mitchellmooreuk/terraform-modules.git`.

## Architecture

- `main.tf` defines providers, Azure resource group, management lock, and a role assignment.
- `app.tf` instantiates reusable modules:
  - `azure-keyvault` module for Key Vault management.
  - `proxmox-vm` module for each Proxmox virtual machine.
- `variables.tf` exposes configuration values for Azure, Proxmox, tagging, and VM definitions.
- `homelab.tfvars` contains the default deployment settings for this homelab.
- `terraform-plan.sh` fetches secrets from Azure Key Vault and runs `terraform init` + `terraform plan`.
- `imports.tf` includes sample import statements for bringing existing Proxmox VMs under Terraform management.

## Prerequisites

- Terraform `>= 1.5.0`
- Azure CLI
- Azure account access and permission to read Key Vault secrets
- Proxmox VE host access with a username/password
- SSH / Git access to `git@github.com:mitchellmooreuk/terraform-modules.git`

## Usage

1. Authenticate to Azure:

```bash
az login
```

2. Confirm the Key Vault secrets are available in `terraform-plan.sh`.

3. Run the plan script:

```bash
./terraform-plan.sh
```

4. Apply the generated plan:

```bash
terraform apply tfplan
```

## Configuration

- `homelab.tfvars` contains the default `application_name`, `owner`, `environment`, `location`, `pve_endpoint`, and VM definitions.
- Sensitive values such as `pve_username`, `pve_password`, and `tenant_id` are retrieved from Azure Key Vault by `terraform-plan.sh`.

## Backend and state

This repository uses an Azure Storage backend configured dynamically by `terraform-plan.sh`.

The script reads backend configuration values from Azure Key Vault secrets:

- `backend-resource-group`
- `backend-storage-account`
- `backend-container-name`
- `backend-state-key`

## Notes

- `azurerm_management_lock.homelab` protects the Azure resource group from accidental deletion.
- The `key_vault` role assignment applies the `Key Vault Secrets Officer` role to a fixed principal ID.
- `imports.tf` contains sample import blocks for existing Proxmox VMs. Update IDs and node names before using.

## Customization

To add or modify VMs, update `homelab.tfvars` under `virtual_machines` and provide appropriate Proxmox network/disks settings.

To override tagging or global settings, update `variables.tf` and `local.global_settings` in `_locals.tf`.

## License

This repository does not include an explicit license. Add one if you intend to share or publish this configuration.
