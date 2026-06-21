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