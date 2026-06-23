# Disclaimer: AI was used to generate this README file, it was edited and reviewed by Mitchell Moore.

# Proxmox HVA01 Configuration (Ansible)
This section contains Ansible automation used to secure, harden, and configure network infrastructure on the **HVA01** Proxmox VE hypervisor node.

## Prerequisites
Before running any playbooks, ensure your local machine the necessary core dependencies and collections installed.

### 1. Install System Dependencies
Ensure Ansible is installed locally:
```bash
sudo dnf install ansible -y
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install azure.azcollection
ansible-galaxy collection install community.crypto
ansible-galaxy collection install kubernetes.core
```
I've used the dnf package manager here, but any package manager can be used really.

### 2. Ensure inventory.ini is correct
```bash
[proxmox_nodes]
HVA01 ansible_host=ip_address_of_HVA01 ansible_user=root
```

### 3. Run HVA01.yaml
This will configure HVA01 by setting network interfaces correctly, generating and injecting an SSH Key to the target node and generating an API key which is then uploaded to Azure Keyvault for authentication via Terraform. It also downloads the Ubuntu Cloud Init image.

```bash
ansible-playbook -i inventory.ini HVA01.yaml -e "keyvault_name=your_key_vault_name_here"
```

# Proxmox Commander VM Configuration (Ansible)
This snippet contains Ansible automation used to secure, harden, and configure network infrastructure on the **HVA01** Proxmox VE hypervisor node.

## Prerequisites
Before running any playbooks, ensure your local machine the necessary core dependencies and collections installed.

### 1. Install System Dependencies
Ensure Ansible is installed locally:
```bash
sudo dnf install ansible -y
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install azure.azcollection
ansible-galaxy collection install community.crypto
ansible-galaxy collection install kubernetes.core
```
I've used the dnf package manager here, but any package manager can be used really.

### 2. Ensure inventory.ini is correct
```bash
[proxmox_nodes]
commander ansible_host=10.25.25.7 ansible_user=ubuntu
```

### 3. Run commander.yaml
This will configure commander by hardening SSH, installing Terraform, AzCli and Ansible.

```bash
ansible-playbook -i inventory.ini commander.yaml
```