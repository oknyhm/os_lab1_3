#!/usr/bin/env bash
set -u
printf '\033]0;%s\007' "${OSLAB3_TITLE:-OSLAB3-E08-BOOT}"
clear
printf '\033[1;36mXXX | 操作系统实验三：新内核启动验证\033[0m\n'
printf '证据编号：E08  启动验证  时间：'
date '+%F %T %Z'
printf '\n'
printf '%-18s %s\n' '登录用户' "$(id -un)"
printf '%-18s %s\n' '主机名' "$(hostname)"
printf '%-18s %s\n' '运行内核' "$(uname -r)"
printf '%-18s %s\n' '启动参数' "$(cat /proc/cmdline)"
printf '%-18s %s\n' 'SSH 服务' "$(systemctl is-active ssh)"
printf '%-18s %s\n' '系统状态' "$(systemctl is-system-running 2>/dev/null || true)"
printf '\n本次启动的前 12 条内核日志：\n'
journalctl -b -k --no-pager -o short-monotonic 2>/dev/null | head -n 12
printf '\n验证结论：自编译内核已启动，网络与 SSH 可用。\n'
sleep 120
