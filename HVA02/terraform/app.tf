module "virtual_machines" {
  for_each = var.virtual_machines

  # source = "git@github.com:mitchellmooreuk/terraform-modules.git//proxmox-vm?ref=v1.6.1"
  source = "/home/mitch/Desktop/projects/terraform-modules/proxmox-vm"

  vm_name         = each.key
  vm_id           = each.value.vm_id
  node_name       = each.value.node_name
  cpu_cores       = each.value.cpu_cores
  cpu_type        = each.value.cpu_type
  memory_mb       = each.value.memory_mb
  bios            = each.value.bios
  clone_vm_id     = each.value.clone_vm_id
  is_template     = each.value.is_template
  scsi_type       = each.value.scsi_type
  vm_description  = each.value.vm_description
  disks           = each.value.disks
  cd_roms         = each.value.cd_roms
  network_devices = each.value.network_devices
}
