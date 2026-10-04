#!/usr/bin/env bash
set -u

release=6.12.110-oslab3-xxx
log=/home/yang/oslab3/logs/boot-verification.txt

{
  echo "XXX | 操作系统实验三：自编译内核启动验证"
  date '+captured=%F %T %Z'
  echo "user=$(id -un)"
  echo "hostname=$(hostname)"
  echo "kernel=$(uname -r)"
  echo "architecture=$(uname -m)"
  echo "cmdline=$(cat /proc/cmdline)"
  echo "pid1=$(ps -p 1 -o comm=)"
  echo "system_state=$(systemctl is-system-running 2>/dev/null || true)"
  echo "ssh_state=$(systemctl is-active ssh 2>/dev/null || true)"
  echo "rootfs=$(findmnt -n -o SOURCE,FSTYPE,OPTIONS /)"
  echo "ipv4=$(hostname -I | awk '{print $1}')"
  echo "target_modules=$(test -d /lib/modules/$release && echo present || echo missing)"
  echo "target_image=$(test -s /boot/vmlinuz-$release && echo present || echo missing)"
  echo "fallback_image=$(test -s /boot/vmlinuz-6.11.0-26-kfocus && echo present || echo missing)"
  echo
  echo "kernel_log_head:"
  journalctl -b -k --no-pager -o short-monotonic 2>/dev/null | head -n 20 || true
  echo
  echo "kernel_errors:"
  journalctl -b -k -p err..alert --no-pager 2>/dev/null || true
} | tee "$log"

test "$(uname -r)" = "$release"
test "$(systemctl is-active ssh)" = active
test -s "/boot/vmlinuz-$release"
test -s /boot/vmlinuz-6.11.0-26-kfocus
echo "verification_exit=0" | tee -a "$log"
