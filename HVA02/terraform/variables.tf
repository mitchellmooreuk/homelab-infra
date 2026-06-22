variable "pve_api_token" {
  type        = string
  description = "(Required) The API token used to authenticated against PVE."
}

variable "pve_endpoint" {
  type        = string
  description = "(Required) The endpoint of the PVE to connect to. Expressed as an IP Address."
}

variable "virtual_machines" {
  type = map(object({
    vm_id          = number
    vm_description = optional(string)
    node_name      = string
    cpu_cores      = number
    cpu_type       = optional(string, "x86-64-v2-AES") # Recommended to use x86-64-v2-AES as per provider docs.
    memory_mb      = number
    bios           = optional(string) # Can be either "seabios" or "ovmf".

    scsi_type = optional(string) # Can be either "virtio-scsi-single" or "virtio-scsi-pci". Defaults to virtio-scsi-pci.

    disks = optional(list(object({
      datastore_id      = string
      size_gb           = number
      interface         = optional(string)
      file_id           = optional(string)
      io_thread         = optional(bool, true)
      file_format       = optional(string, "raw")
      type              = optional(string, "4m") # Size and type of OVMF EFI Disk. Only required if BIOS is set to OVMF.
      pre_enrolled_keys = optional(bool, true)
    })), [])

    cd_roms = optional(list(object({
      file_name = optional(string)
      interface = optional(string)
    })), [])

    network_devices = list(object({
      bridge      = string
      model       = string
      vlan_id     = optional(number)
      mac_address = optional(string)
    }))

    ipv4_address = optional(string)
    gateway      = optional(string)
  }))
  description = "(Optional) A map of virtual machines to be provisoned"
  default     = {}
}
