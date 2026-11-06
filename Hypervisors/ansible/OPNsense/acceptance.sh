#!/usr/bin/env bash
# Disclaimer: This script was generated with AI.
#
# Acceptance checks for OPNsense. Run from a single-homed VM tagged into the
# VLAN under test, not from a multi-homed host.
#
#   ./acceptance.sh client 10.25.10.1 staging
#   ./acceptance.sh client 10.25.10.1 live
#   ./acceptance.sh management 10.25.25.1 staging
#
# Staging has no WAN and can't reach AdGuard or HVA01, so those checks are
# skipped, and the HVA01 namespace stands in as the internal target.

set -u

ROLE=${1:?usage: acceptance.sh client|management GATEWAY staging|live}
GW=${2:?usage: acceptance.sh client|management GATEWAY staging|live}
STAGE=${3:?usage: acceptance.sh client|management GATEWAY staging|live}

ADGUARD=10.25.25.4
if [ "$STAGE" = "staging" ]; then
  INTERNAL=10.25.25.2
else
  INTERNAL=10.25.25.250
fi

failures=0

expect_pass() {
  local name=$1
  shift
  if "$@" >/dev/null 2>&1; then
    echo "PASS  $name"
  else
    echo "FAIL  $name (expected to work)"
    failures=$((failures + 1))
  fi
}

expect_fail() {
  local name=$1
  shift
  if "$@" >/dev/null 2>&1; then
    echo "FAIL  $name (expected to be blocked)"
    failures=$((failures + 1))
  else
    echo "PASS  $name"
  fi
}

skip() {
  echo "SKIP  $1"
}

check_lease() {
  local prefix=${GW%.*}
  local host
  host=$(ip -4 -o addr show scope global | awk '{print $4}' | cut -d/ -f1 | grep "^${prefix}\." | head -n1 | cut -d. -f4)
  [ -n "$host" ] && [ "$host" -ge 100 ] && [ "$host" -le 200 ]
}

check_dns_lease() {
  grep -q "$ADGUARD" /etc/resolv.conf || resolvectl dns 2>/dev/null | grep -q "$ADGUARD"
}

client_checks() {
  expect_fail "ping gateway" ping -c2 -W2 "$GW"
  expect_fail "ping internal host" ping -c2 -W2 "$INTERNAL"
  expect_fail "firewall GUI on gateway" curl -m5 -k "https://$GW"
  expect_fail "DNS on gateway" dig +time=2 +tries=1 +short @"$GW" example.com

  if [ "$STAGE" = "live" ]; then
    local wan_ip
    wan_ip=$(curl -s -m5 https://ifconfig.me)
    expect_pass "fetch WAN IP" test -n "$wan_ip"
    expect_fail "firewall GUI on WAN IP" curl -m5 -k "https://$wan_ip"
    expect_pass "DNS through AdGuard" dig +time=2 +tries=1 @"$ADGUARD" example.com
    expect_pass "HTTPS to the internet" curl -sfm5 -o /dev/null https://example.com
  else
    skip "WAN and AdGuard checks need the live network"
  fi
}

management_checks() {
  expect_pass "ping firewall" ping -c2 -W2 "$GW"
  expect_pass "firewall GUI" curl -sm5 -k -o /dev/null "https://$GW"
  expect_fail "firewall SSH closed" timeout 5 bash -c "</dev/tcp/$GW/22"
  expect_fail "firewall HTTP closed" timeout 5 bash -c "</dev/tcp/$GW/80"
  expect_pass "internal host reachable" ping -c2 -W2 "$INTERNAL"

  if [ "$STAGE" = "live" ]; then
    expect_pass "HTTPS to the internet" curl -sfm5 -o /dev/null https://example.com
  else
    skip "internet checks need the live network"
  fi
}

expect_pass "lease from the expected pool" check_lease
expect_pass "AdGuard handed out over DHCP" check_dns_lease

case "$ROLE" in
  client) client_checks ;;
  management) management_checks ;;
  *) echo "Unknown role: $ROLE"; exit 2 ;;
esac

echo
echo "$failures failure(s)"
[ "$failures" -eq 0 ]
