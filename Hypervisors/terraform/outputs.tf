output "ansible_inventory" {
  description = "VM names and IPs, grouped for the Ansible inventory."
  value = {
    for group in local.ansible_groups : group => {
      for name, vm in var.virtual_machines : name => split("/", vm.cloud_init.ipv4_address)[0]
      if vm.ansible_group == group
    }
  }
}
