Disclaimer: AI was used to generate this file.

# Homelab Infrastructure

The goal for this repository is to put most of my homelab configuration into Terraform and Ansible to make it easy to rebuild should I ever have to. This repo should never expose the names of any Azure resources, nor should it ever expose any secrets or sensitive values. Any resources should be locked down as much as possible (within reason), whilst ensuring cost efficiency remains a priority. This repository is not representitive of an enterprise environment, nor is it how I would configure an enterprise environment; but as I don't have enterprise money I have to get creative to balance both security and cost simultaneously 😅

## Roadmap
- Provision remote state and an azure key vault to retrieve secrets at runtime [✅]
- Create a terraform modules repository to enable remote module storage including versioning of modules [✅]
- Get all virtual machines into Terraform [✅]
- Make this deployable via GitHub actions using CI/CD pipelines []
- Provision scripts to backup configuration for switches, firewalls, access points etc []
- Provision a VM with a cron job that goes away and grabs those backups every x amount of time, saves them to my NAS and remote storage of some kind []
- Get a personal website up and running in Azure with CI/CD pipelines for this []

## Overview

This repository provisions a homelab infrastructure using:

- Azure Resource Manager (`azurerm`) for cloud state backend, resource group, management lock, and Key Vault.
- Proxmox provider (`bpg/proxmox`) for creating and managing VMs on a Proxmox VE host.
- Remote Terraform modules from `git@github.com:mitchellmooreuk/terraform-modules.git`.

## Architecture

- `main.tf` defines providers, Azure resource group, management lock, and a role assignment.
- `app.tf` instantiates reusable modules
- `variables.tf` exposes configuration values for Azure, Proxmox, tagging, and VM definitions.
- `homelab.tfvars` contains the default deployment settings for this homelab.
- `terraform-plan.sh` fetches secrets from Azure Key Vault and runs `terraform init` + `terraform plan`. Handles IP lifecycle management to both the storage account and key vault.

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
./terraform-plan.sh '<additional command line params can be found in 1Pass for running this locally.>'
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

- `backend-container-name`
- `backend-state-key`

## Notes

- `azurerm_management_lock.homelab` protects the Azure resource group from accidental deletion.
- The `key_vault` role assignment applies the `Key Vault Secrets Officer` role to a fixed principal ID (Entra ID Security Group).
- All resources are tagged correctly

## License

This repository does not include an explicit license. Add one if you intend to share or publish this configuration.
