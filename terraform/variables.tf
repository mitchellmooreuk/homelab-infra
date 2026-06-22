variable "application_name" {
  type        = string
  description = "The name of the application for which resources are being deployed."
}

variable "environment" {
  type        = string
  description = "The environment in which the resources are being deployed."
}

variable "owner" {
  type        = string
  description = "The owner of the resources being deployed."
}

variable "location" {
  type        = string
  description = "The location in which the resources are being deployed."
}

variable "tenant_id" {
  type        = string
  description = "The ID of the Azure tenant."
}

variable "global_settings" {
  type        = map(any)
  description = "A map of global settings that can be used to override default values for resources."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "(Optional) A map of tags to add to the resource"
  default     = {}
}

variable "pve_api_token" {
  type        = string
  description = "(Required) The API token used to authenticated against PVE."
}

variable "pve_endpoint" {
  type        = string
  description = "The endpoint of the PVE to connect to. Expressed as an IP Address."
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

    disks = list(object({
      datastore_id      = string
      size_gb           = number
      interface         = string
      io_thread         = optional(bool, true)
      file_format       = optional(string, "raw")
      type              = optional(string, "4m") # Size and type of OVMF EFI Disk. Only required if BIOS is set to OVMF.
      pre_enrolled_keys = optional(bool, true)
    }))

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
