# OPNsense migration: implementation brief

Brief for Claude Code. Goal: write the Terraform and Ansible to build an OPNsense VM that replaces the pfSense VM (VM 100) on HVA01, with config held as code. **Write code and open a PR only. Do not apply anything, and do not touch the live pfSense VM.**

## Context

- Repo: `mitchellmooreuk/homelab-infra`. Terraform (`bpg/proxmox` provider, existing `proxmox-vm` module with a `cloud_init` variable) and Ansible. GitHub Actions with OIDC, a self-hosted runner, reusable `workflow_call` templates. Follow the existing module, variable and workflow conventions; read them before writing anything.
- Applies run from the self-hosted runner, not from the machine Claude Code runs on. That machine is on an isolated VLAN with internet only: it cannot reach Proxmox, pfSense or any internal host. Don't try.
- No secrets in code. API tokens, the OPNsense API key/secret and passwords come from GitHub secrets/vars, matching the existing pattern.

## Current state (pfSense 22.9, VM 100 on HVA01)

| vNIC | Bridge | MAC | Role |
|---|---|---|---|
| net0 | vmbr1 | BC:24:11:93:CD:48 | WAN (DHCP from Virgin Media Hub in modem mode) |
| net1 | vmbr2 | BC:24:11:D5:3E:C9 | Unused, retired LAN |
| net2 | vmbr0 | BC:24:11:79:5D:4D | VLAN trunk (802.1Q: 10, 20, 25, 26) |

No packages, VPNs, port forwards, static routes, DHCP reservations or IPv6 internally.

## Target design

### VM

- Host HVA01. Two virtio NICs only, Proxmox firewall disabled on both (`firewall=0`), no `tag=`, trunk NIC must pass VLANs 10/20/25/26.
  - `net0`: WAN, bridge `vmbr1`. MAC is a variable. Default to an auto-generated MAC for staging; at cutover it is set to `BC:24:11:93:CD:48` while pfSense is powered off. Never both live.
  - `net1`: trunk. Bridge is a variable: `vmbr9` (staging) or `vmbr0` (production).
- CPU/RAM: match VM 100 (variables; read actual values from `qm config 100` at apply time, don't guess).
- Not started on boot (`onboot = false`) until cutover.

### Staging bridge (Proxmox host, HVA01)

`vmbr9`: VLAN-aware, `bridge-ports none`, `bridge-vids 2-4094`, no IP. Isolated so OPNsense can run with production IPs alongside pfSense without duplicate gateways or DHCP servers. Manage via Ansible against `/etc/network/interfaces` (or a drop-in) with `ifreload -a`; check how the repo already manages host networking first.

### Interfaces

Assign VLAN 25 as the OPNsense **LAN** interface (anti-lockout lands on management, not the dev VLAN). VLAN 26 must be an OPT interface.

| OPNsense name | VLAN | Parent | Address | DHCP pool | DHCP DNS |
|---|---|---|---|---|---|
| WAN | n/a | vtnet0 | DHCP (IPv4); block private and bogon **off** | n/a | n/a |
| LAN (MANAGEMENT) | 25 | vtnet1 | 10.25.25.1/24 | .100-.200 | 10.25.25.4 |
| LAN_VLAN | 10 | vtnet1 | 10.25.10.1/24 | .100-.200 | 10.25.25.4 |
| IOT_VLAN | 20 | vtnet1 | 10.25.20.1/24 | .100-.200 | 10.25.25.4 |
| VMVLAN | 26 | vtnet1 | 10.25.26.1/24 | .100-.199 | 10.25.25.4 |

Gateway handed out is each interface's .1. DHCP backend: Kea or dnsmasq (not legacy ISC). No static reservations.

### System

Hostname `opnsense` (confirm), domain `slug.internal`, system DNS 10.25.25.4, timezone UTC, SSH disabled, GUI HTTPS only. Hardware offloads (checksum, TSO, LRO) disabled. Unbound: not used by clients; disable or bind to nothing client-facing.

### Aliases

- `RFC1918` (network): 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
- `AdGuard` (host): 10.25.25.4
- `FW_Admin_Ports` (port): 443

### Firewall rules (IPv4, first match wins, in this order)

**LAN_VLAN, IOT_VLAN, VMVLAN** (identical):

| # | Action | Proto | Source | Destination | Log |
|---|---|---|---|---|---|
| 1 | Pass | TCP/UDP | net | AdGuard:53 | |
| 2 | Block | any | net | This Firewall | yes |
| 3 | Block | any | net | RFC1918 | yes |
| 4 | Pass | any | net | any | |

**MANAGEMENT (LAN)**:

| # | Action | Proto | Source | Destination | Log |
|---|---|---|---|---|---|
| 1 | Pass | TCP | net | This Firewall:FW_Admin_Ports | |
| 2 | Pass | ICMP echo-request | net | This Firewall | |
| 3 | Block | any | net | This Firewall | yes |
| 4 | Pass | any | net | RFC1918 | yes |
| 5 | Pass | any | net | any | |

**WAN**: no pass rules.

**Outbound NAT**: automatic mode, no manual rules.

## Deliverables

1. Terraform: OPNsense VM via the existing `proxmox-vm` module (extend the module only if it can't express two NICs with per-NIC bridge/MAC/firewall settings; keep changes backward compatible).
2. Ansible: `vmbr9` staging bridge on HVA01.
3. OPNsense configuration as code (aliases, rules, DHCP, NAT mode, system settings) using whichever tool you confirm works; see open questions.
4. A GitHub Actions workflow (or extension of an existing one) for plan/apply, following the repo's reusable templates.
5. `docs/opnsense-cutover.md`: bootstrap steps that can't be automated, cutover and rollback.
6. A test script for the acceptance checks below.

## Open questions: verify before building, report back in the PR description

1. **Bootstrap.** OPNsense has no native cloud-init. Determine the cleanest way to get an initial install with interface assignment and an API key: ISO plus manual console steps, a pre-built image, or importing a generated `config.xml`. Document what remains manual.
2. **Config-as-code tooling.** Check the current resource coverage of the `browningluke/opnsense` Terraform provider and the `ansibleguy.opnsense` Ansible collection against the deliverables above (aliases, rules with ordering, Kea/dnsmasq DHCP, outbound NAT mode, interface/VLAN assignment). Pick one, justify it, list gaps.
3. **API reachability during staging.** In staging, OPNsense's management IP (10.25.25.1) sits on isolated `vmbr9` and the runner can't reach it. Propose a solution (e.g. a temporary extra management NIC, applying config only after cutover, or a staging-time config import). Don't silently pick one; lay out the options.
4. **VM 100 sizing and disk/storage layout**: parameterise; don't hardcode guesses.

## Acceptance checks (run from single-homed test VMs tagged into each VLAN, not a multi-homed host)

From VLANs 10, 20, 26 (substitute the VLAN's gateway):

```bash
WANIP=$(curl -s -m5 https://ifconfig.me)       # works
ping -c2 -W2 $GW                                 # fails
ping -c2 -W2 10.25.25.250                        # fails
curl -m5 -k https://$GW                          # fails
curl -m5 -k https://$WANIP                       # fails
dig +time=2 +tries=1 @$GW example.com            # fails
dig +time=2 +tries=1 @10.25.25.4 example.com     # works
curl -sm5 -o /dev/null -w '%{http_code}\n' https://example.com   # 200
```

From VLAN 25: GUI on https://10.25.25.1 works, ping 10.25.25.1 works, other firewall ports fail, internal VLANs reachable. Every VLAN gets a lease from the expected pool.

## Out of scope

Applying anything, cutover, changes to pfSense, the TP-Link switch, AdGuard, or DNS enforcement (redirecting port 53 / blocking 853), which is a later phase.
