#!/usr/bin/env bash
set -u
clear
cd "$HOME/oslab3/src/linux-6.12.110"
printf '\033[1;36mXXX | 操作系统实验三：启动源码定位\033[0m\n'
printf '证据编号：E03  Linux 6.12.110 x86_64 启动路径  时间：'
date '+%F %T %Z'
printf '\n阶段与关键入口（文件:行号）：\n'
grep -nE '^_start:' arch/x86/boot/header.S
grep -nE '^void main\(void\)' arch/x86/boot/main.c
grep -nE '^void go_to_protected_mode\(void\)' arch/x86/boot/pm.c
grep -nE 'SYM_FUNC_START\(startup_32\)|startup_64:' arch/x86/boot/compressed/head_64.S | head -n 4
grep -nE 'SYM_CODE_START_NOALIGN\(startup_64\)' arch/x86/kernel/head_64.S
grep -nE 'void start_kernel\(void\)|rest_init\(void\)|kernel_init\(void' init/main.c
printf '\n调用主线：\n'
printf 'BIOS -> GRUB -> boot/main.c -> protected mode\n'
printf '     -> compressed startup_64 -> kernel startup_64\n'
printf '     -> start_kernel -> rest_init -> kernel_init -> systemd\n'
printf '\nstart_kernel() 入口源码：\n'
nl -ba init/main.c | sed -n '868,878p'
sleep 120
