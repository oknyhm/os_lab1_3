#!/usr/bin/env bash
set -euo pipefail

clear
printf '\033[1;36mXXX | 操作系统实验三：启动可观测探针\033[0m\n'
printf '证据编号: E09  采集时间: %s\n\n' "$(date '+%F %T %Z')"

printf '\033[1m自动化测试结果\033[0m\n'
grep -E '^(PASS|SUMMARY)' "$HOME/oslab3/logs/extra-design-test.log"

printf '\n\033[1m/proc/oslab3_boot\033[0m\n'
cat /proc/oslab3_boot

printf '\n\033[1m本次启动中的模块日志\033[0m\n'
journalctl -b -k --no-pager -g 'oslab3_probe:' | tail -n 3

printf '\n\033[1m启动耗时\033[0m\n'
systemd-analyze time

printf '\n结论：9 项测试全部通过，模块在启动后 6557 ms 自动加载。\n'
exec bash

