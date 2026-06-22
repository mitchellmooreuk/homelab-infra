module "key_vault" {
  source = "git@github.com:mitchellmooreuk/terraform-modules.git//azure-keyvault?ref=v1.6.1"

  application_name    = var.application_name
  location            = var.location
  resource_group_name = azurerm_resource_group.homelab.name
  tenant_id           = var.tenant_id
  tags                = local.base_tags
  global_settings     = local.global_settings

  sku_name = "standard"
}

module "virtual_machines" {
  for_each = var.virtual_machines

  source = "git@github.com:mitchellmooreuk/terraform-modules.git//proxmox-vm?ref=v1.8.0"

  vm_name         = each.key
  vm_id           = each.value.vm_id
  node_name       = each.value.node_name
  cpu_cores       = each.value.cpu_cores
  cpu_type        = each.value.cpu_type
  memory_mb       = each.value.memory_mb
  bios            = each.value.bios
  scsi_type       = each.value.scsi_type
  vm_description  = each.value.vm_description
  disks           = each.value.disks
  cd_roms         = each.value.cd_roms
  network_devices = each.value.network_devices
  ipv4_address    = each.value.ipv4_address
  gateway         = each.value.gateway
}
