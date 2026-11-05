# OPNsense cutover

Disclaimer: AI was used to generate this file.

How to build OPNsense (VM 104) on HVA01, test it in isolation, and swap it in for pfSense (VM 100). See [opnsense-migration-plan.md](opnsense-migration-plan.md) for the design.

**The pipeline can't deploy this.** The apply job is disabled, and the runner relies on pfSense for internet access. Run Terraform by hand from commander, and do the cutover itself on HVA01.

## 1. Build the staging network

Run from commander:

```bash
cd Hypervisors/ansible/HVA01
ansible-playbook -i inventory.ini staging-bridge.yaml --private-key ~/.ssh/id_rsa_terraform
```

Do not re-run `HVA01.yaml` for this. It rotates the Proxmox API token but only updates Key Vault.

Check it on HVA01:

```bash
ip -d link show vmbr9
ip netns exec opnstage ip -br addr
systemctl status opnsense-staging-ns opnsense-staging-relay
```

## 2. Create the VM

Confirm VM 100's sizing with `qm config 100`, and that VM ID 104 is free. Then, from commander:

```bash
cd Hypervisors/terraform
./terraform-plan.ps1 -nodeName HVA01 -keyVaultName <vault> -resourceGroupName <rg> -storageAccountName <storage>
terraform apply tfplan
```

**Stop if the plan touches anything other than the `opnsense` VM and its ISO**, or a replacement of the Ubuntu image, which happens whenever Ubuntu publishes a new build. The VM is created powered off, with `net0` disconnected. Check the ISO attached with `qm config 104`.

## 3. Bootstrap

OPNsense has no cloud-init, so this part is manual, in the Proxmox console for VM 104.

1. Verify the ISO on HVA01. The [published checksum](https://pkg.opnsense.org/releases/26.7/OPNsense-26.7-checksums-amd64.sha256) is for the compressed file, so check that first, then compare its contents with the ISO Proxmox unpacked:
   ```bash
   curl -fsSL -o /tmp/opnsense.iso.bz2 https://pkg.opnsense.org/releases/26.7/OPNsense-26.7-dvd-amd64.iso.bz2
   curl -fsSL https://pkg.opnsense.org/releases/26.7/OPNsense-26.7-checksums-amd64.sha256 | grep dvd
   sha256sum /tmp/opnsense.iso.bz2
   bunzip2 -c /tmp/opnsense.iso.bz2 | cmp - /var/lib/vz/template/iso/OPNsense-26.7-dvd-amd64.iso && echo match
   rm /tmp/opnsense.iso.bz2
   ```
2. Start the VM. Log in as `installer` with password `opnsense`, and install to the disk.
3. Shut down, detach the ISO from `ide2`, and start the VM again.
4. Use console option `1) Assign interfaces`:
   - Say yes to VLANs, and create tag `25` on `vtnet1`.
   - WAN: `vtnet0`. LAN: the new VLAN device.
5. Use console option `2) Set interface IP address` on LAN: `10.25.25.1/24`, no upstream gateway, no DHCP. Stay on HTTPS.
6. Change the root password with console option `3`, and store it in 1Password.

Then open the tunnel from a machine on the management network, and browse to `https://127.0.0.1:8443`:

```bash
ssh -N -L 8443:127.0.0.1:8443 root@10.25.25.250
```

If the GUI reports a DNS rebind or referrer error, set the option to disable those checks under System > Settings > Administration, then re-enable them after cutover.

In the GUI, set the following by hand:

| Setting | Value |
|---|---|
| Hostname, domain | `opnsense`, `slug.internal` |
| System DNS | `10.25.25.4` |
| Timezone | UTC |
| Interface name | Rename LAN to `MANAGEMENT` |
| Administration | HTTPS only, HTTP redirect disabled, SSH disabled |

Create a dedicated user with an API key under System > Access > Users, and copy the key file to `~/.opnsense/api.txt` on commander.

## 4. Apply the configuration

Follow [the OPNsense README](../Hypervisors/ansible/OPNsense/README.md).

Check Firewall > Rules afterwards. Delete any default allow rules left on LAN that the playbook didn't create, and confirm Firewall > NAT shows automatic outbound mode with no manual rules.

Run the playbook a second time. It should report almost no changes. If it keeps changing the same tasks, note them before going further.

## 5. Test in staging

Test VMs need `curl`, `dig` and a DHCP client installed **before** they move to `vmbr9`, because there's no internet there. On HVA01, for each VLAN:

```bash
qm set <test-vm> --net0 virtio,bridge=vmbr9,tag=10
```

Copy `Hypervisors/ansible/OPNsense/acceptance.sh` to the VM, then run it from the VM's console:

```bash
./acceptance.sh client 10.25.10.1 staging      # also 10.25.20.1 and 10.25.26.1
./acceptance.sh management 10.25.25.1 staging
```

Internet and AdGuard checks are skipped, as neither is reachable from `vmbr9`.

Run the namespace-based GUI check as well: `https://127.0.0.1:8443` should still load. **Don't cut over until every check passes.**

## 6. Cut over

Pick a quiet window. You lose internet from step 2 here, so have this doc saved offline. Run everything from a root shell on HVA01. You can reach HVA01 over VLAN 25 throughout, as it doesn't need the firewall, but keep the local console available.

Take a backup of pfSense first, and a snapshot of OPNsense:

```bash
qm snapshot 104 pre-cutover
```

1. Note the MAC of `net1`, as `qm set` replaces the whole NIC definition:
   ```bash
   qm config 104 | grep -E '^net'
   ```
2. Stop pfSense, and stop it starting by itself:
   ```bash
   qm shutdown 100 --timeout 120
   qm set 100 --onboot 0
   ```
3. Confirm it's stopped with `qm status 100`. **The two firewalls must never be up on the same networks.**
4. Move OPNsense to production:
   ```bash
   qm stop 104
   qm set 104 --net0 virtio=BC:24:11:93:CD:48,bridge=vmbr1,firewall=0
   qm set 104 --net1 virtio=<net1-mac>,bridge=vmbr0,firewall=0
   qm set 104 --onboot 1
   qm start 104
   ```
5. Check OPNsense gets a WAN lease, under Interfaces > Overview or at the console.
6. Run the checks from a real device on each VLAN:
   ```bash
   ./acceptance.sh client 10.25.10.1 live         # also 10.25.20.1 and 10.25.26.1
   ./acceptance.sh management 10.25.25.1 live
   ```

If the WAN doesn't come up, leave it a few minutes, then consider power cycling the Hub. If it's still down or the checks fail, roll back.

## Rollback

```bash
qm stop 104
qm set 104 --onboot 0
qm set 104 --net0 virtio=BC:24:11:93:CD:48,bridge=vmbr1,firewall=0,link_down=1
qm set 104 --net1 virtio=<net1-mac>,bridge=vmbr9,firewall=0
qm set 100 --onboot 1
qm start 100
```

pfSense itself hasn't changed, so this restores the previous state. Devices may hold OPNsense leases until they renew, but the pools and gateways match.

## 7. After cutover

**Do not run `terraform apply` until `HVA01.tfvars` has been updated.** The file still describes staging, and `pfsense` defaults to `started = true`, so an apply could power pfSense back on while OPNsense holds its WAN MAC.

1. Update `HVA01.tfvars`, then check the plan shows no changes to these VMs beyond matching reality:
   ```hcl
   # pfsense
   on_boot = false
   started = false

   # opnsense
   on_boot = true
   started = true
   # net0: mac_address = "BC:24:11:93:CD:48", and remove disconnected
   # net1: bridge = "vmbr0", and set mac_address to the value from qm config
   ```
2. Update OPNsense through the GUI to the latest 26.7.x. Update the commit pinned in `requirements.yml` if needed, then re-run the playbook directly against `10.25.25.1` to check for drift.
3. Replace the staging test VMs' NICs, and remove the ISO from `opnsense` in `HVA01.tfvars`.
4. Once you're happy, tear down staging, which refuses to run while any VM still uses `vmbr9`:
   ```bash
   ansible-playbook -i inventory.ini staging-teardown.yaml --private-key ~/.ssh/id_rsa_terraform
   ```
5. Delete the `pre-cutover` snapshot. Keep VM 100 powered off until you're confident, then remove it from Terraform in a separate change.
