pve_endpoint = "https://10.25.25.249:8006/"

virtual_machines = {
  "k8s-controller-01" = {
    vm_id       = 100
    node_name   = "HVA02"
    cpu_cores   = 2
    memory_mb   = 2048
    bios        = "seabios"
    clone_vm_id = 100

    scsi_type = "virtio-scsi-single"

    disks = [{
      datastore_id = "local-lvm"
      file_format  = "raw"
      file_id      = "local:iso/ubuntu-24.04-cloudimage.img"
      interface    = "scsi0"
      io_thread    = true
      size_gb      = 32
    }]

    network_devices = [
      {
        bridge      = "vmbr0" # net0
        model       = "virtio"
        mac_address = "BC:24:11:93:CD:48"
        vlan_id     = 25
      }
    ]

    ipv4_address = "10.25.25.5/24"
    gateway      = "10.25.25.1"
  },
  "k8s-worker-01" = {
    vm_id       = 101
    node_name   = "HVA02"
    cpu_cores   = 4
    memory_mb   = 4096
    bios        = "seabios"
    clone_vm_id = 100

    scsi_type = "virtio-scsi-single"

    disks = [{
      datastore_id = "local-lvm"
      file_format  = "raw"
      file_id      = "local:iso/ubuntu-24.04-cloudimage.img"
      interface    = "scsi0"
      io_thread    = true
      size_gb      = 32
    }]

    network_devices = [
      {
        bridge      = "vmbr0" # net0
        model       = "virtio"
        mac_address = "BC:24:11:77:43:75"
        vlan_id     = 25
      }
    ]

    ipv4_address = "10.25.25.6/24"
    gateway      = "10.25.25.1"
  }
}
