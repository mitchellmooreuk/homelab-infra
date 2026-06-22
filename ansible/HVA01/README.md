# Disclaimer: AI was used to generate this README file, it was edited and reviewed by Mitchell Moore.

# Proxmox Host Configuration (Ansible)
This directory contains Ansible automation used to secure, harden, and configure network infrastructure on the **HVA01** Proxmox VE hypervisor node.

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

If this is the first time you are running Ansible against HVA01, you MUST run the command below with "-u root --ask-pass" appended. The reason for this is because HVA01 hasn't yet had any SSH keys copied over to it, so password authentication is the only option here. Subsequent runs of Ansible against HVA01 require this to be removed, as SSH hardening has taken place and the configuration file for sshd has been edited to reject PasswordAuthentication.
```bash
ansible-playbook -i inventory.ini generate-api-token.yml -e "keyvault_name=your_key_vault_name_here"
```

### Fin!