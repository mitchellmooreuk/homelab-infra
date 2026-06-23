pve_endpoint = "https://10.25.25.249:8006/"

image_download = {
  "ubuntu_24_04" = {
    content_type = "import"
    datastore_id = "local"
    node_name    = "HVA02"
    url          = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
    file_name    = "noble-server-cloudimg-amd64.qcow2"
  }
}

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
      import_from  = "local:import/noble-server-cloudimg-amd64.qcow2"
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

    cloud_init = {
      datastore_id = "local-lvm"
      interface    = "ide0"
      ipv4_address = "10.25.25.5/24"
      gateway      = "10.25.25.1"
    }
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
      import_from  = "local:import/noble-server-cloudimg-amd64.qcow2"
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

    cloud_init = {
      datastore_id = "local-lvm"
      interface    = "ide0"
      ipv4_address = "10.25.25.6/24"
      gateway      = "10.25.25.1"
    }
  }
}
