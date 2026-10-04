#!/usr/bin/env bash
set -euo pipefail

fstab=/etc/fstab
stamp=$(date '+%Y%m%d-%H%M%S')
backup="/etc/fstab.oslab3-before-libvirt-fix-${stamp}.bak"
record=/home/yang/oslab3/logs/fstab-backup.txt

match_count=$(grep -F -c 'subvol=@libvirt-machines/@' "$fstab")
if [ "$match_count" -ne 2 ]; then
  echo "refusing: expected exactly 2 stale libvirt entries, found $match_count" >&2
  exit 42
fi

cp -a "$fstab" "$backup"
{
  echo "backup=$backup"
  sha256sum "$backup"
} | tee "$record"

sed -i \
  '/ subvol=@libvirt-machines\/@etc-libvirt,/s/^/# oslab3-disabled-stale-subvolume /;
   / subvol=@libvirt-machines\/@var-lib-libvirt,/s/^/# oslab3-disabled-stale-subvolume /' \
  "$fstab"

disabled_count=$(grep -F -c '# oslab3-disabled-stale-subvolume ' "$fstab")
test "$disabled_count" -eq 2

systemctl daemon-reload
mount -a
systemctl reset-failed etc-libvirt.mount var-lib-libvirt.mount || true

echo '== disabled entries =='
grep -F '# oslab3-disabled-stale-subvolume ' "$fstab"
echo '== remaining failed units =='
systemctl --failed --no-pager || true
echo 'fstab_fix_exit=0'
