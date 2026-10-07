#!/usr/bin/env bash
# Run from the repository root, or pass a directory containing both test files.
set -u
test_dir=${1:-tests}
failures=0
run() {
  printf '\nCOMMAND:'
  printf ' %q' "$@"
  printf '\n'
  "$@"
  rc=$?
  printf 'command_exit=%s\n' "$rc"
  if (( rc != 0 )); then failures=$((failures + 1)); fi
}
printf 'XXX | OS lab 3 supplemental VM verification\n'
printf 'collected_at=%s\n' "$(date --iso-8601=seconds)"
run id
run uname -r
run cat /proc/sys/kernel/random/boot_id
run uptime -s
run findmnt -n -o SOURCE,FSTYPE,OPTIONS /
run sha256sum "$test_dir/test_boot_probe.sh" "$test_dir/check_probe_contract.py"
run bash "$test_dir/test_boot_probe.sh"
run python3 "$test_dir/check_probe_contract.py"
run cat /etc/modules-load.d/oslab3_probe.conf
run systemctl show systemd-modules-load.service -p Result -p ExecMainStatus -p ActiveEnterTimestampMonotonic
run journalctl -b -u systemd-modules-load.service --no-pager -o short-monotonic
run journalctl -b -k --no-pager -o short-monotonic -g oslab3_probe
printf '\nCOLLECTION_SUMMARY command_failures=%s\n' "$failures"
exit "$failures"
