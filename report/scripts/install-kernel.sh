#!/usr/bin/env bash
set -euo pipefail

src=/home/yang/oslab3/src/linux-6.12.110
release=6.12.110-oslab3-xxx
install_log=/home/yang/oslab3/logs/install.log

exec > >(tee "$install_log") 2>&1

cd "$src"
actual=$(make -s kernelrelease)
test "$actual" = "$release"
test -s arch/x86/boot/bzImage
test -s vmlinux

echo "== pre-install /boot space =="
df -h /boot
echo "== installing modules =="
make modules_install
echo "== installing kernel image =="
make install

if ! test -s "/boot/initrd.img-$release"; then
  echo "== creating initramfs =="
  update-initramfs -c -k "$release"
fi

echo "== refreshing GRUB =="
update-grub

echo "== installed artifacts =="
ls -lh "/boot/vmlinuz-$release" "/boot/initrd.img-$release" \
  "/boot/System.map-$release" "/boot/config-$release"
test -d "/lib/modules/$release"

echo "== retained fallback kernel =="
ls -lh /boot/vmlinuz-6.11.0-26-kfocus /boot/initrd.img-6.11.0-26-kfocus

echo "== GRUB kernel references =="
grep -n -E "6[.]12[.]110-oslab3-xxx|6[.]11[.]0-26-kfocus" \
  /boot/grub/grub.cfg | head -n 20

echo "install_exit=0"
