application_name = "homelab"
owner            = "Mitchell Moore"
environment      = "prod"
location         = "uksouth"

pve_endpoint = "https://10.25.25.250:8006/"

virtual_machines = {
  "pfsense" = {
    vm_id     = 100
    node_name = "proxmox"
    cpu_cores = 2
    memory_mb = 4096
    bios      = "ovmf"

    scsi_type = "virtio-scsi-single"

    disks = [
      {
        datastore_id      = "local-lvm"
        size_gb           = 20
        interface         = "scsi0"
        io_thread         = true
        type              = "4m"
        pre_enrolled_keys = true
      }
    ]

    network_devices = [
      {
        bridge      = "vmbr1" # net0
        model       = "virtio"
        mac_address = "BC:24:11:93:CD:48"
      },
      {
        bridge      = "vmbr2" # net1
        model       = "virtio"
        mac_address = "BC:24:11:D5:3E:C9"
      },
      {
        bridge      = "vmbr0" # net2
        model       = "virtio"
        mac_address = "BC:24:11:79:5D:4D"
      }
    ]
  },
  unifi = {
    vm_id     = 101
    node_name = "proxmox"
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
        mac_address = "BC:24:11:77:43:75"
        vlan_id     = 25
      }
    ]
  },
  adguard = {
    vm_id     = 102
    node_name = "proxmox"
    cpu_cores = 2
    memory_mb = 2048
    bios      = "seabios"

    scsi_type = "virtio-scsi-single"

    disks = [
      {
        datastore_id      = "local-lvm"
        size_gb           = 8
        interface         = "scsi0"
        io_thread         = true
        type              = "4m"
        pre_enrolled_keys = true
      }
    ]

    cd_roms = [
      {
        file_name = "local:iso/ubuntu-24.04.4-live-server-amd64.iso"
        interface = "ide2"
      }
    ]

    network_devices = [
      {
        bridge      = "vmbr0" # net0
        model       = "virtio"
        mac_address = "BC:24:11:9F:FE:44"
        vlan_id     = 25
      }
    ]
  },
  "commander" = {
    vm_id     = 103
    node_name = "proxmox"
    cpu_cores = 2
    memory_mb = 1024
    bios      = "seabios"

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

    cd_roms = [
      {
        file_name = "local:iso/ubuntu-24.04.4-live-server-amd64.iso"
        interface = "ide2"
      }
    ]

    network_devices = [
      {
        bridge      = "vmbr0" # net0
        model       = "virtio"
        mac_address = "BC:24:11:9F:FE:44"
        vlan_id     = 25
      }
    ]
  }
}
