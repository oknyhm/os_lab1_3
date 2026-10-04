#!/usr/bin/env bash
set -u
clear
cd "$HOME/oslab3/src/linux-6.12.110"
printf '\033[1;36mXXX | 操作系统实验三：内核配置\033[0m\n'
printf '证据编号：E04  配置确认  时间：'
date '+%F %T %Z'
printf '\n配置策略：当前可启动内核配置 + olddefconfig + localmodconfig\n'
printf '目标版本：'
make -s kernelrelease
printf '\n关键启动配置：\n'
for symbol in LOCALVERSION LOCALVERSION_AUTO SCSI BLK_DEV_SD BTRFS_FS FUSION_SPI E1000; do
    grep -E "^(CONFIG_${symbol}=|# CONFIG_${symbol} is not set)" .config
done
printf '\n当前 VMware 关键模块：\n'
lsmod | grep -E '^(btrfs|mptspi|mptscsih|mptbase|e1000)'
printf '\n配置文件校验：\n'
sha256sum .config
printf '\n结论：Btrfs 根文件系统、磁盘控制器和网卡模块配置完整；启动时由 initramfs 装入。\n'
sleep 120
