#!/usr/bin/env bash
set -euo pipefail

expected_kernel="6.12.110-oslab3-xxx"
running_kernel="$(uname -r)"

if [[ "$running_kernel" != "$expected_kernel" ]]; then
  printf 'ERROR: expected kernel %s, running %s\n' "$expected_kernel" "$running_kernel" >&2
  exit 1
fi

make
sudo install -D -m 0644 oslab3_probe.ko \
  "/lib/modules/${running_kernel}/extra/oslab3_probe.ko"
sudo depmod -a "$running_kernel"
sudo install -D -m 0644 oslab3_probe.conf \
  /etc/modules-load.d/oslab3_probe.conf

if lsmod | grep -q '^oslab3_probe '; then
  sudo modprobe -r oslab3_probe
fi
sudo modprobe oslab3_probe

printf 'Installed module: %s\n' "$(modinfo -F filename oslab3_probe)"
cat /proc/oslab3_boot

