#!/usr/bin/env bash
set -euo pipefail

output_dir="${1:-$HOME/oslab3/logs}"
mkdir -p "$output_dir"

{
  printf 'OS lab 3 boot performance evidence\n'
  printf 'collected_at=%s\n' "$(date --iso-8601=seconds)"
  printf 'kernel=%s\n\n' "$(uname -r)"
  systemd-analyze time
  printf '\nTop services by activation time:\n'
  systemd-analyze blame | sed -n '1,15p'
  printf '\nCritical chain:\n'
  systemd-analyze critical-chain
} | tee "$output_dir/boot-performance.txt"

# This is standard-output redirection, not journal logging.
systemd-analyze plot > "$output_dir/boot-analysis.svg"
printf 'plot=%s\n' "$output_dir/boot-analysis.svg"
