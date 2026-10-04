#!/usr/bin/env bash
set -u
clear
printf '\033[1;36mXXX | 操作系统实验三：Linux 启动初始化过程探析\033[0m\n'
printf '证据编号：E01  环境基线  时间：'
date '+%F %T %Z'
printf '\n'
printf '%-18s %s\n' '登录用户' "$(id -un)"
printf '%-18s %s\n' '主机名' "$(hostname)"
printf '%-18s %s\n' '发行版' "$(lsb_release -ds 2>/dev/null)"
printf '%-18s %s\n' '当前内核' "$(uname -r)"
printf '%-18s %s\n' '体系结构' "$(uname -m)"
printf '%-18s %s\n' '处理器数量' "$(nproc)"
printf '%-18s %s\n' 'IPv4 地址' "$(hostname -I | awk '{print $1}')"
printf '\n内存状态：\n'
free -h
printf '\n磁盘状态：\n'
df -h / /boot 2>/dev/null
printf '\n编译工具：\n'
gcc --version | head -n 1
make --version | head -n 1
printf '\nSSH 状态：'
systemctl is-active ssh
printf '\n该画面由 Kubuntu 桌面终端现场生成，个人信息暂以 XXX 占位。\n'
sleep 120
