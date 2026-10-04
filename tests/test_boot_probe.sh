#!/usr/bin/env bash
set -u

expected_kernel="6.12.110-oslab3-xxx"
failures=0

pass() { printf 'PASS %-28s %s\n' "$1" "$2"; }
fail() { printf 'FAIL %-28s %s\n' "$1" "$2"; failures=$((failures + 1)); }

actual_kernel="$(uname -r)"
if [[ "$actual_kernel" == "$expected_kernel" ]]; then
  pass T01-kernel "$actual_kernel"
else
  fail T01-kernel "expected=$expected_kernel actual=$actual_kernel"
fi

if lsmod | grep -q '^oslab3_probe '; then
  pass T02-module-loaded "$(lsmod | awk '$1 == "oslab3_probe" {print $1, $2, $3}')"
else
  fail T02-module-loaded "oslab3_probe is absent from lsmod"
fi

if [[ -r /proc/oslab3_boot ]]; then
  pass T03-proc-readable "/proc/oslab3_boot"
else
  fail T03-proc-readable "/proc/oslab3_boot is not readable"
fi

probe_status="$(awk -F= '$1 == "status" {print $2}' /proc/oslab3_boot 2>/dev/null || true)"
if [[ "$probe_status" == "ready" ]]; then
  pass T04-proc-status "$probe_status"
else
  fail T04-proc-status "expected=ready actual=${probe_status:-missing}"
fi

load_ms="$(awk -F= '$1 == "module_load_boottime_ms" {print $2}' /proc/oslab3_boot 2>/dev/null || true)"
if [[ "$load_ms" =~ ^[0-9]+$ ]] && (( load_ms < 120000 )); then
  pass T05-boot-autoload "loaded_at=${load_ms}ms"
else
  fail T05-boot-autoload "load time missing or too late: ${load_ms:-missing}"
fi

if journalctl -b -k --no-pager -g 'oslab3_probe: init' | grep -q 'oslab3_probe: init'; then
  pass T06-kernel-log "init record found in current boot"
else
  fail T06-kernel-log "current-boot init record missing"
fi

system_state="$(systemctl is-system-running 2>/dev/null || true)"
if [[ "$system_state" == "running" ]]; then
  pass T07-system-state "$system_state"
else
  fail T07-system-state "$system_state"
fi

ssh_state="$(systemctl is-active ssh 2>/dev/null || true)"
if [[ "$ssh_state" == "active" ]]; then
  pass T08-ssh "$ssh_state"
else
  fail T08-ssh "$ssh_state"
fi

failed_units="$(systemctl --failed --no-legend | sed '/^[[:space:]]*$/d' | wc -l)"
if [[ "$failed_units" -eq 0 ]]; then
  pass T09-failed-units "0"
else
  fail T09-failed-units "$failed_units"
fi

printf '\n/proc/oslab3_boot\n'
cat /proc/oslab3_boot 2>/dev/null || true
printf '\nSUMMARY tests=9 failures=%d result=%s\n' \
  "$failures" "$([[ "$failures" -eq 0 ]] && printf PASS || printf FAIL)"

exit "$failures"

