#!/usr/bin/env bash
set -u
printf '\033]0;%s\007' "${OSLAB3_TITLE:-OSLAB3-E05-BUILD}"
clear
printf '\033[1;36mXXX | 操作系统实验三：内核编译结果\033[0m\n'
printf '证据编号：E05  编译完成  时间：'
date '+%F %T %Z'
printf '\n内核源码：Linux 6.12.110 (kernel.org longterm)\n'
printf '配置后缀：-oslab3-xxx\n\n'
cat "$HOME/oslab3/logs/build.status" 2>/dev/null || true
cat "$HOME/oslab3/logs/build-time.txt" 2>/dev/null || true
printf '\n关键产物：\n'
ls -lh "$HOME/oslab3/src/linux-6.12.110/arch/x86/boot/bzImage" \
       "$HOME/oslab3/src/linux-6.12.110/vmlinux" 2>/dev/null || true
printf '\n编译日志末尾：\n'
tail -n 18 "$HOME/oslab3/logs/build.log" 2>/dev/null || true
sleep 120
