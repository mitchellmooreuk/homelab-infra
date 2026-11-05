# Disclaimer: AI was used to generate this README file.

# OPNsense Configuration (Ansible)
This directory configures the OPNsense VM over its API. See [docs/opnsense-cutover.md](../../../docs/opnsense-cutover.md) for the full process, including the steps that can't be automated.

## Prerequisites
Run these from commander, which needs SSH access to HVA01.

### 1. Install dependencies
```bash
sudo apt install -y python3-venv
python3 -m venv ~/.venvs/opnsense
~/.venvs/opnsense/bin/pip install httpx==0.28.1 h11==0.16.0
ansible-galaxy collection install -r requirements.yml
```
The venv is needed because the collection failed on larger API responses with Ubuntu 24.04's `python3-httpx` packages. `inventory.ini` points at it.

The collection is pinned to a commit, because no tagged release supports OPNsense 26.7 yet. Each release only supports its matching OPNsense version, so update this pin whenever OPNsense is upgraded.

### 2. Add the API key
Save the key file downloaded from OPNsense to `~/.opnsense/api.txt` on commander, and `chmod 600` it. Never commit this file.

### 3. Open the staging tunnel
OPNsense is isolated on `vmbr9` during staging, so the API is reached through the relay on HVA01:
```bash
ssh -i ~/.ssh/id_rsa_terraform -N -L 8443:127.0.0.1:8443 root@10.25.25.250
```

### 4. Run opnsense.yaml
```bash
ansible-playbook -i inventory.ini opnsense.yaml --check --diff
ansible-playbook -i inventory.ini opnsense.yaml --diff
```
`--check` won't fully work on a fresh firewall, because later tasks read interfaces created by earlier ones.

After cutover, skip the tunnel and target the firewall directly:
```bash
ansible-playbook -i inventory.ini opnsense.yaml --diff -e "opnsense_host=10.25.25.1 opnsense_port=443"
```

## What isn't covered
Hostname, domain, system DNS, timezone, SSH and the HTTP redirect have no API or module to manage them, so they're set by hand. Outbound NAT stays in its default automatic mode, so it needs no configuration. Both are covered in the cutover doc.
