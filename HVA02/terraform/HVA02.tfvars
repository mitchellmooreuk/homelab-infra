pve_endpoint = "https://10.25.25.249:8006/"

virtual_machines = {
  "ubuntu-template" = {
    vm_id       = 100
    node_name   = "HVA02"
    cpu_cores   = 1
    memory_mb   = 1024
    bios        = "ovmf"
    is_template = true

    scsi_type = "virtio-scsi-single"

    disks = [
      {
        datastore_id = "local-lvm"
        file_id      = "local:iso/ubuntu-24.04-cloudimage.img"
        interface    = "scsi0"
        size_gb      = 32
        file_format  = "raw"
      }
    ]

    network_devices = [
      {
        bridge      = "vmbr0" # net0
        model       = "virtio"
        mac_address = "BC:24:11:D2:0F:2F"
      }
    ]
  },
  "k8-controller" = {
    vm_id       = 101
    node_name   = "HVA02"
    cpu_cores   = 2
    memory_mb   = 2048
    bios        = "ovmf"
    clone_vm_id = 100

    scsi_type = "virtio-scsi-single"

    network_devices = [
      {
        bridge      = "vmbr0" # net0
        model       = "virtio"
        mac_address = "BC:24:11:93:CD:48"
        vlan_id     = 25
      }
    ]
  },
  "k8-worker" = {
    vm_id       = 102
    node_name   = "HVA02"
    cpu_cores   = 4
    memory_mb   = 4096
    bios        = "ovmf"
    clone_vm_id = 100

    scsi_type = "virtio-scsi-single"

    network_devices = [
      {
        bridge      = "vmbr0" # net0
        model       = "virtio"
        mac_address = "BC:24:11:77:43:75"
        vlan_id     = 25
      }
    ]
  }
}
