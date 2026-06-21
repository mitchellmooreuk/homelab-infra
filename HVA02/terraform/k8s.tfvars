pve_endpoint = "https://10.25.25.249:8006/"

virtual_machines = {
  "k8-controller" = {
    vm_id     = 100
    node_name = "HVA02"
    cpu_cores = 2
    memory_mb = 2048
    bios      = "ovmf"

    scsi_type = "virtio-scsi-single"

    disks = [
      {
        datastore_id      = "local-lvm"
        size_gb           = 16
        interface         = "scsi0"
        io_thread         = true
        type              = "4m"
        pre_enrolled_keys = true
      }
    ]

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
    vm_id     = 101
    node_name = "HVA02"
    cpu_cores = 4
    memory_mb = 4096
    bios      = "ovmf"

    scsi_type = "virtio-scsi-single"

    disks = [
      {
        datastore_id      = "local-lvm"
        size_gb           = 64
        interface         = "scsi0"
        io_thread         = true
        type              = "4m"
        pre_enrolled_keys = true
      }
    ]

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
