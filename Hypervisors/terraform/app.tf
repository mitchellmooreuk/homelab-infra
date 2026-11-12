module "download_image" {
  for_each = var.image_download

  source = "git::https://github.com/mitchellmooreuk/terraform-modules.git//proxmox-download-image?ref=v1.10.1"

  content_type = each.value.content_type
  datastore_id = each.value.datastore_id
  node_name    = each.value.node_name
  url          = each.value.url
  file_name    = each.value.file_name

  decompression_algorithm = each.value.decompression_algorithm
  overwrite               = each.value.overwrite
}

module "virtual_machines" {
  for_each = var.virtual_machines

  source = "git::https://github.com/mitchellmooreuk/terraform-modules.git//proxmox-vm?ref=v1.11.0"

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
  cloud_init      = each.value.cloud_init
  ssh_public_keys = [local.ssh_public_key]
  firewall_rules  = each.value.firewall_rules
  on_boot         = each.value.on_boot
  started         = each.value.started

  depends_on = [module.download_image]
}
