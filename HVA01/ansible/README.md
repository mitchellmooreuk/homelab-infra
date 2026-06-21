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
```
I've used the dnf package manager here, but you can use whatever your machine is running.

### 2. Ensure inventory.ini is correct
```bash
[proxmox_nodes]
HVA01 ansible_host=ip_address_of_HVA01 ansible_user=root
```

### 3. Run secure-ssh.yml
This will ensure that password authentication is disabled. You will need to populate the 'my_public_key' variable with your public key first.
```bash
ansible-playbook -i inventory.ini secure-ssh.yml -k
```
Then ensure that the SSH hardening actually worked by running:
```bash
ssh -o PubkeyAuthentication=no root@10.25.25.250
``` 
You should see an output similar to # Expected output: Permission denied (publickey).

### 4. Configure the vmbr to be vlan aware
```bash
ansible-playbook -i inventory.ini configure-network.yml
```

### 5. Generate API token for Terraform
```bash
ansible-playbook -i inventory.ini generate-api-token.yml -e "keyvault_name=your_key_vault_name_here"
```

### Fin!