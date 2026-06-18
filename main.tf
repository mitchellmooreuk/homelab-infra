terraform {
  required_version = ">= 1.5.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.70.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.pve_endpoint
  insecure = true
  username = var.pve_username
  password = var.pve_password
}
