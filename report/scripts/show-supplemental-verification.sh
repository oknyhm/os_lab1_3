#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
clear
printf 'XXX | OS lab 3 | Supplemental VM verification\n'
printf 'Screenshot time: %s\n' "$(date --iso-8601=seconds)"
printf 'Live kernel: %s\n' "$(uname -r)"
printf 'Live boot ID: %s\n\n' "$(cat /proc/sys/kernel/random/boot_id)"
printf 'Saved test output (not a new test run):\n'
grep -E '^(collected_at=|PASS |SUMMARY |COLLECTION_SUMMARY)' live-verification.txt
printf '\nFull command output and exit codes: live-verification.txt\n'
printf 'T05 is a timing heuristic, not proof of automatic loading.\n'
exec bash
