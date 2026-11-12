locals {
  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_file)))

  ansible_groups = distinct([for vm in var.virtual_machines : vm.ansible_group if vm.ansible_group != null])
}
