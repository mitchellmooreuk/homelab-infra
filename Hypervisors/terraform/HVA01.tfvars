application_name = "homelab"
owner            = "Mitchell Moore"
environment      = "prod"
location         = "uksouth"

pve_endpoint = "https://10.25.25.250:8006/"

image_download = {
  "ubuntu_24_04" = {
    content_type = "import"
    datastore_id = "local"
    node_name    = "proxmox"
    url          = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
    file_name    = "noble-server-cloudimg-amd64.qcow2"
  }
  "opnsense_26_7" = {
    content_type            = "iso"
    datastore_id            = "local"
    node_name               = "proxmox"
    url                     = "https://pkg.opnsense.org/releases/26.7/OPNsense-26.7-dvd-amd64.iso.bz2"
    file_name               = "OPNsense-26.7-dvd-amd64.iso"
    decompression_algorithm = "bz2"
  }
}

virtual_machines = {
  "pfsense" = {
    vm_id          = 100
    vm_description = "The VM for PfSense."
    node_name      = "proxmox"
    cpu_cores      = 2
    memory_mb      = 3072
    bios           = "ovmf"

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
    vm_id          = 101
    vm_description = "The VM for the Unifi controller."
    node_name      = "proxmox"
    cpu_cores      = 2
    memory_mb      = 2048
    bios           = "ovmf"

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
    vm_id          = 102
    vm_description = "The VM for AdGuard."
    node_name      = "proxmox"
    cpu_cores      = 2
    memory_mb      = 2048
    bios           = "seabios"

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
  "opnsense" = {
    vm_id          = 104
    vm_description = "The VM for OPNsense. Staged on vmbr9, see docs/opnsense-cutover.md."
    node_name      = "proxmox"
    cpu_cores      = 2
    memory_mb      = 3072
    bios           = "ovmf"
    on_boot        = false
    started        = false

    scsi_type = "virtio-scsi-single"

    disks = [
      {
        datastore_id      = "local-lvm"
        size_gb           = 20
        interface         = "scsi0"
        io_thread         = true
        type              = "4m"
        pre_enrolled_keys = false # OPNsense is not signed for Secure Boot.
      }
    ]

    cd_roms = [
      {
        file_name = "local:iso/OPNsense-26.7-dvd-amd64.iso"
        interface = "ide2"
      }
    ]

    network_devices = [
      {
        bridge       = "vmbr1" # net0
        model        = "virtio"
        disconnected = true # Stays unplugged until cutover.
      },
      {
        bridge = "vmbr9" # net1
        model  = "virtio"
      }
    ]
  },
  "commander" = {
    vm_id          = 103
    vm_description = "A Command VM that interfaces with other VMs on the network."
    node_name      = "proxmox"
    cpu_cores      = 2
    memory_mb      = 1024
    bios           = "seabios"

    scsi_type = "virtio-scsi-single"

    disks = [
      {
        datastore_id = "local-lvm"
        import_from  = "local:import/noble-server-cloudimg-amd64.qcow2"
        interface    = "scsi0"
        io_thread    = true
        size_gb      = 32
      }
    ]

    network_devices = [
      {
        bridge      = "vmbr0" # net0
        model       = "virtio"
        mac_address = "BC:24:11:4D:E4:FB"
        vlan_id     = 25
      }
    ]

    cloud_init = {
      datastore_id = "local-lvm"
      interface    = "ide0"
      ipv4_address = "10.25.25.7/24"
      gateway      = "10.25.25.1"
    }
  }
}
