#!/usr/bin/env bash
set -u

src=/home/yang/oslab3/src/linux-6.12.110
logs=/home/yang/oslab3/logs

cd "$src" || exit 1
cp -f "$logs/build.log" "$logs/build-attempt1.log"
rm -f "$logs/build.status" "$logs/build-time.txt"

started=$(date '+%F %T %Z')
printf 'started=%s\n' "$started" > "$logs/build.status.running"

set +e
/usr/bin/time -f 'elapsed=%E\nmax_rss_kb=%M\nexit=%x' \
  -o "$logs/build-time.txt" \
  make -j2 > "$logs/build.log" 2>&1
rc=$?
set -e

{
  printf 'build_exit=%s\n' "$rc"
  printf 'finished=%s\n' "$(date '+%F %T %Z')"
} > "$logs/build.status"
rm -f "$logs/build.status.running"
exit "$rc"
