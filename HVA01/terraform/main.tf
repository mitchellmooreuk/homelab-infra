terraform {
  required_version = ">= 1.5.0"

  backend "azurerm" {}

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.110.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.78.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "proxmox" {
  endpoint  = var.pve_endpoint
  insecure  = true
  api_token = var.pve_api_token
}

resource "azurerm_resource_group" "homelab" {
  name     = "rg-homelab-infra"
  location = var.location
  tags     = var.tags
}

resource "azurerm_management_lock" "homelab" {
  name       = "rg-homelab-infra-lock"
  scope      = azurerm_resource_group.homelab.id
  lock_level = "CanNotDelete"
  notes      = "Prevents the accidental deletion of the resource group and its resources."
}

resource "azurerm_role_assignment" "key_vault" {
  scope                = module.key_vault.keyvault_id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = "eb23335d-3b10-4fe0-a190-02cf0476c6d2"
}
