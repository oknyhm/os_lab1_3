# 功能、实现与测试矩阵

证据采集日期：2026-09-21；文档复核：2026-10-05。下列日志路径均位于 `report/logs/`。
本次仓库发布不构成重新运行 Linux 测试，历史源代码与日志配套保留。

| 声明功能 | 实现位置 | 测试命令或脚本 | 实际证据 |
|---|---|---|---|
| 自编译内核可启动 | Linux 6.12.110 配置及构建脚本 | `uname -r` | `boot-verification.txt` |
| Btrfs 根文件系统可用 | 内核配置、initramfs | `findmnt /` | `boot-verification.txt` |
| SSH 可供 Agent 操作 | OpenSSH 公钥认证 | `ssh -o BatchMode=yes` | 环境及启动验证日志 |
| 旧内核文件及 GRUB 条目保留 | 内核安装过程 | 检查 `grub.cfg` 和映像 | `install.log`；未重新启动旧内核验证回退 |
| 探针可手动加载和卸载 | `oslab3_probe.c` | `modprobe`、`modprobe -r` | `extra-design-manual-test.log` |
| 探针提供只读 procfs 状态 | `oslab3_probe.c` | `cat /proc/oslab3_boot` | `extra-design-test.log` |
| 探针在当次重启后较早加载 | `oslab3_probe.conf` | 重启后执行测试脚本，期间未手动加载 | T05 PASS，6557 ms；需结合配置和操作过程判断自动加载 |
| 内核日志记录模块生命周期 | `pr_info()` | `journalctl -b -k -g oslab3_probe` | T06 PASS |
| 系统启动性能可分析 | `collect-boot-performance.sh` | `systemd-analyze` | `boot-performance.txt`、SVG |

所有“支持”声明必须在本表中同时具有实现、测试和实际结果；没有证据的项目不写入 README 或报告结论。

## 九项检查逐项说明

| 编号 | 代码中的实际判定 | 2026-09-21 输出 | 限制 |
|---|---|---|---|
| T01 | `uname -r` 等于目标版本 | PASS | 只支持此实验内核版本 |
| T02 | `lsmod` 含模块名 | PASS | 不验证所有模块功能 |
| T03 | procfs 文件可读 | PASS | 不含并发/权限攻击测试 |
| T04 | `status` 等于 `ready` | PASS | 未校验每个字段的语义 |
| T05 | 装载时间为数字且小于 120000 ms | PASS，6557 ms | 不能单独排除早期手动加载 |
| T06 | 本次启动内核日志含 init 标记 | PASS | 依赖 journal 读取权限 |
| T07 | systemd 返回 running | PASS | 反映采集时刻 |
| T08 | SSH 服务为 active | PASS | 服务状态以外，实际 SSH 命令执行另外佐证连通性 |
| T09 | 失败单元行数为 0 | PASS | 未独立检查查询命令退出码 |

`collect-boot-verification.sh` 是历史采集脚本，未启用逐项失败退出。其 `verification_exit=0`
不能单独用作全部检查成功的证明；本报告采用实际输出字段、探针测试日志与截图交叉核对。

## 手动生命周期测试命令

原手动测试使用以下命令序列，结果保存于 `extra-design-manual-test.log`，不是独立自动化用例：

```bash
modinfo -F filename oslab3_probe
cat /proc/oslab3_boot
sudo modprobe -r oslab3_probe
test ! -e /proc/oslab3_boot && echo 'PASS unload: proc entry removed'
sudo modprobe oslab3_probe
test -r /proc/oslab3_boot && echo 'PASS reload: proc entry restored'
journalctl -b -k --no-pager -g 'oslab3_probe:' | tail -n 6
```

对应日志包含卸载/重载的 PASS 及 init/exit 记录。模块编译和安装结果另见 `extra-design-install.log`。

## 证据尚未覆盖的内容

- 旧内核实际回退启动、模块签名、不同硬件或不同内核兼容性。
- 并发读/卸载压力、错误注入、安装失败回滚、所有脚本错误路径。
- 多轮启动性能统计、优化前后比较、每个源码入口的执行轨迹。
- 带个人信息标题的原始对话截图和本人对关键原理的现场解释。
