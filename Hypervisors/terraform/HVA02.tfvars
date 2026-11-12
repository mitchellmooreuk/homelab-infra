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
  "k8s-int-cp" = {
    vm_id          = 100
    vm_description = "Internal cluster control plane."
    node_name      = "HVA02"
    cpu_cores      = 2
    memory_mb      = 4096
    bios           = "seabios"
    ansible_group  = "k8s_int"

    scsi_type = "virtio-scsi-single"

    disks = [
      {
        datastore_id = "local-lvm"
        import_from  = "local:import/noble-server-cloudimg-amd64.qcow2"
        interface    = "scsi0"
        io_thread    = true
        size_gb      = 20
      }
    ]

    network_devices = [
      {
        bridge  = "vmbr0" # net0
        model   = "virtio"
        vlan_id = 27
      }
    ]

    cloud_init = {
      datastore_id = "local-lvm"
      interface    = "ide0"
      ipv4_address = "10.25.27.2/24"
      gateway      = "10.25.27.1"
      dns_servers  = ["1.1.1.1", "1.0.0.1"]
    }
  },
  "k8s-int-w1" = {
    vm_id          = 101
    vm_description = "Internal cluster worker."
    node_name      = "HVA02"
    cpu_cores      = 4
    memory_mb      = 8192
    bios           = "seabios"
    ansible_group  = "k8s_int"

    scsi_type = "virtio-scsi-single"

    disks = [
      {
        datastore_id = "local-lvm"
        import_from  = "local:import/noble-server-cloudimg-amd64.qcow2"
        interface    = "scsi0"
        io_thread    = true
        size_gb      = 30
      },
      {
        datastore_id = "local-lvm"
        interface    = "scsi1"
        io_thread    = true
        size_gb      = 20
      }
    ]

    network_devices = [
      {
        bridge  = "vmbr0" # net0
        model   = "virtio"
        vlan_id = 27
      }
    ]

    cloud_init = {
      datastore_id = "local-lvm"
      interface    = "ide0"
      ipv4_address = "10.25.27.3/24"
      gateway      = "10.25.27.1"
      dns_servers  = ["1.1.1.1", "1.0.0.1"]
    }
  },
  "k8s-dmz-1" = {
    vm_id          = 102
    vm_description = "DMZ cluster single node."
    node_name      = "HVA02"
    cpu_cores      = 2
    memory_mb      = 4096
    bios           = "seabios"
    ansible_group  = "k8s_dmz"

    scsi_type = "virtio-scsi-single"

    disks = [
      {
        datastore_id = "local-lvm"
        import_from  = "local:import/noble-server-cloudimg-amd64.qcow2"
        interface    = "scsi0"
        io_thread    = true
        size_gb      = 20
      }
    ]

    network_devices = [
      {
        bridge   = "vmbr0" # net0
        model    = "virtio"
        vlan_id  = 11
        firewall = true
      }
    ]

    cloud_init = {
      datastore_id = "local-lvm"
      interface    = "ide0"
      ipv4_address = "10.25.11.2/24"
      gateway      = "10.25.11.1"
      dns_servers  = ["1.1.1.1", "1.0.0.1"]
    }

    firewall_rules = [
      {
        comment = "SSH from commander"
        source  = "10.25.25.7"
        proto   = "tcp"
        dport   = "22"
      },
      {
        comment = "Kubernetes API from commander"
        source  = "10.25.25.7"
        proto   = "tcp"
        dport   = "6443"
      }
    ]
  }
}
