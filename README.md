# os_lab1_3

操作系统实验三：Linux 启动初始化过程探析。平台为 VMware 中的 Kubuntu 24.04.3 LTS，目标内核为 `6.12.110-oslab3-xxx`。仓库名按提交要求使用 `os_lab1_3`，内容仅包含实验三。

[实验报告 PDF](output/pdf/实验三_Linux启动初始化过程探析_XXX.pdf) · [XeLaTeX 源文件](report/main.tex) · [测试矩阵](docs/test-matrix.md) · [Agent 交互记录](ai-record/README.md)

## 完成情况与证据

基础实验运行证据采集于 **2026-09-21**，**2026-10-05** 首次发布。**2026-10-07 18:18（UTC+8）** 在用户开启的虚拟机内完成补测：历史九项检查再次 9/9 通过，补充接口检查 6/6 通过。早先 SSH 超时后仅完成本机自测的状态已由本次实机结果补齐；历史日志不覆盖。下表原有构建、性能数字仍为 9 月 21 日记录。

| 内容 | 已观察到的结果 | 证据 |
|---|---|---|
| 源码研读、配置和构建 | 6.12.110，成功构建耗时 1:12:32；首轮 BTF 构建失败如实保留 | [构建状态](report/logs/build.status)、[完整日志](report/logs/build.log)、[耗时](report/logs/build-time.txt) |
| 新内核实际启动 | `6.12.110-oslab3-xxx`，Btrfs 根分区可用、PID 1 为 systemd、SSH active | [启动验证](report/logs/boot-verification.txt) |
| emergency mode 排查 | fstab 指向排查时不存在的两个 libvirt 子卷；先备份再修复，重启恢复 | [备份记录](report/logs/fstab-backup.txt)、报告第 6、9 章 |
| 额外设计：内核启动探针 | `/proc/oslab3_boot` 提供开机相对时间、内核版本与状态；可加载/卸载 | [源码](extra-design/oslab3_probe.c)、[手动测试日志](report/logs/extra-design-manual-test.log) |
| 探针启动后检查 | 当次 9 项检查全部 PASS，装载时间为开机后 6557 ms | [测试脚本](tests/test_boot_probe.sh)、[结果](report/logs/extra-design-test.log) |
| 启动性能观测 | 内核 5.890 s + 用户空间 7.305 s；工具报告总计 13.196 s | [性能记录](report/logs/boot-performance.txt)、[原始 SVG](report/figures/boot-analysis.svg) |
| 10 月 7 日实机补测 | 九项复验 9/9、补充检查 6/6；本次装载时间 6370 ms | [完整命令、退出码及输出](report/logs/supplemental-vm-20261007.txt)、[真实终端截图](report/figures/supplemental-test-20261007.png) |

报告封面姓名为毛灏洋，学号为 24281070；历史日志、截图及内核版本中的 `XXX` 标识保持原样。已收录四张带个人标题的[对话截图](ai-record/README.md)，其中一张经授权仅遮盖密码值，保留用户名及消息其他内容，原图仅留本地；同时保留文字节选和事后摘要。截图未覆盖全部故障诊断与探针设计轮次。历史回复中的 EXT4 口误、旧版报告页数均已在索引说明。

## 文件范围

报告现将四张对话来源图以九幅原像素分段单页展示，便于放大阅读；原图、裁切坐标及像素一致性复现脚本均保留，分段不代表新增对话证据。

```text
AGENTS.md                         后续 Agent 的工作约定
README.md                         范围、复现入口、结果和限制
extra-design/                     探针 C 源码、Makefile、安装脚本、加载配置
tests/                            历史九项检查、补充接口检查及性能采集脚本
report/main.tex                   报告源文件
report/scripts/                   原实验执行、采集和截图辅助脚本
report/logs/                      原始编译、安装、启动与测试日志及内核配置
report/figures/                   七张实机截图和原始启动时序 SVG
output/pdf/                       一份最终报告 PDF
docs/                            测试矩阵、证据 SHA-256 清单
ai-record/                       经审阅的对话截图、文字节选与证据索引
```

未纳入 Linux 完整源码、虚拟磁盘、`.ko` 等编译产物、TeX 中间文件、调试版 PDF、教师实验指导书，以及凭据。日志和原始截图保留了实验主机名、虚拟机用户名和 NAT 私网地址，便于核对同一次实验。

## 复现条件

以下步骤面向该实验虚拟机。探针安装脚本要求当前运行版本精确为 `6.12.110-oslab3-xxx`，且 `/lib/modules/$(uname -r)/build` 指向**已完成构建、含对应配置和 Module.symvers** 的源码目录。不能仅用另一版本的发行版 headers 替代，也不能把本仓库当成可直接引导的完整系统镜像。

Linux 内核来自 [官方源码压缩包](https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.12.110.tar.xz)；下载内容的本地摘要见 [SHA-256 记录](report/logs/linux-6.12.110.sha256)，最终配置见 [配置文件](report/logs/kernel-config-6.12.110-oslab3-xxx)。摘要记录用于核对实验工件，不等同于完成官方签名验证。

内核配置、构建、安装及引导步骤见报告第 5 章。`report/scripts/` 中的历史脚本含 `/home/yang/oslab3` 等实验路径，部分会安装内核或修改 fstab，应先理解并核对环境。fstab 修复针对当时的两条陈旧记录，已修复的虚拟机无需重跑。原内核文件和 GRUB 条目仍保留；本实验未重新启动旧内核验证回退。

## 运行启动探针

在目标内核启动的虚拟机内操作，普通用户执行以下命令；安装时由 sudo 请求权限：

```bash
cd extra-design
bash install-probe.sh
cat /proc/oslab3_boot
```

安装脚本会编译模块，将其放入当前内核的 `extra/` 目录，执行 `depmod`，安装 modules-load 配置并立即加载模块。模块采用 GPL 声明，但没有签名；当时内核允许其加载并记录树外/未签名 taint 提示，该提示保留在日志和报告中。

要复验自动加载，应在安装完成后重启，在**没有手动 modprobe** 的情况下运行检查。以下命令从仓库根目录执行，把新结果放到仓库外，保留历史证据：

```bash
sudo reboot
# 重连 SSH 后进入仓库根目录
run_dir="$(mktemp -d /tmp/oslab3-run.XXXXXX)"
set -o pipefail
bash tests/test_boot_probe.sh 2>&1 | tee "$run_dir/probe-test.log"
test_rc=${PIPESTATUS[0]}
printf 'test_exit=%s\n' "$test_rc"
bash tests/collect-boot-performance.sh "$run_dir"
```

检查日志需要当前用户能够读取 system journal（原实验用户有权限）。卸载实验模块可用 `sudo modprobe -r oslab3_probe`，再次加载可用 `sudo modprobe oslab3_probe`；检查 `/proc/oslab3_boot` 的消失/恢复，并查询 `journalctl -b -k -g 'oslab3_probe:'`。这仅卸载当前模块；modules-load 配置仍会在下一次启动时加载它。

## 测试边界

- T05 检查装载时间小于 120000 ms，单独不能排除开机后迅速手动加载。6557 ms 自动加载的结论还依赖安装配置、实际重启以及未手动加载的操作记录。
- T09 检查失败单元数量，没有独立检查查询命令的退出状态。九项 PASS 是此次检查的实际输出，不代表全面故障覆盖。
- 历史 `collect-boot-verification.sh` 未逐步失败退出，`verification_exit=0` 不能单独证明所有条件成功；需看日志字段和后续探针测试结果。
- 手动加载/卸载属于记录了命令与结果的手动测试，命令见测试矩阵。代码未加入故障注入、并发读取/卸载压力测试、跨内核兼容测试或模块签名。
- 模块加载时间对应用户空间加载模块阶段，不是 `start_kernel()` 运行时间。单次启动耗时没有优化前后多轮对照，不声明性能提升。
- 报告的启动流程图是源码支持的路径分析；未做 GRUB 实际跳转地址追踪或逐指令验证。

## 补充检查（与历史九项测试分开）

`tests/check_probe_contract.py` 使用 Python 3 标准库，检查字段完整性、内核/状态一致性、两次读取的时间关系、0444 权限、拒绝写打开，以及失败单元查询的退出状态。写打开检查不截断文件、不写入数据，使用普通用户执行；它不证明 root/并发/攻击场景安全性，也不证明自动加载。

本机夹具自测：`python tests/check_probe_contract.py --self-test`，8 项通过，原始输出见 [自测日志](report/logs/contract-self-test-20261007.txt)。这是判定逻辑自测，与实机结果分开记录。

实机补测：普通用户 UID 1000 执行，E01–E06 全部 PASS。两次当前开机时间为 653292/653343 ms，装载时间均为 6370 ms；权限为 0444，写打开返回 EACCES（errno=13），失败单元查询退出码 0 且输出为空。完整日志记录启动 ID、脚本 SHA-256 与每条命令退出码，见 [补测日志](report/logs/supplemental-vm-20261007.txt)。

本次未重装内核、重启或手动重载模块。启动 ID 为 `be9c2642-9f41-488d-b332-7abd572119e1`；加载服务 Result=success、ExecMainStatus=0，内核日志含初始化记录，但该服务的 journal 查询为空。配置、早期装载时间和内核日志相互支持，不把“服务日志为空但命令返回 0”视为完整自动加载轨迹。

可从仓库根目录执行 `bash report/scripts/run-supplemental-verification.sh` 收集相同项目；该脚本不重启、不安装模块。截图是 Konsole 展示保存的测试输出，同时核对当前内核与 boot ID，截图时刻与测试时刻明确分开。

在目标虚拟机、仓库根目录执行下列命令收集新结果：
```bash
run_dir="$(mktemp -d /tmp/oslab3-contract.XXXXXX)"
set -o pipefail
python3 tests/check_probe_contract.py 2>&1 | tee "$run_dir/contract.log"
test_rc=${PIPESTATUS[0]}
printf 'test_exit=%s\n' "$test_rc" | tee -a "$run_dir/contract.log"
```
不要安装/重载模块后把此结果称为“自动加载复验”；复验自动加载仍需独立记录重启过程。

## 编译报告

安装含中文支持的 TeX Live、XeLaTeX、Fandol 和 TeX Gyre 字体后，从仓库根目录运行：

```bash
cd report
xelatex -interaction=nonstopmode -halt-on-error main.tex
xelatex -interaction=nonstopmode -halt-on-error main.tex
```

源文件使用 TeX 字体文件名查找，不依赖 Windows 盘符。此次已在 TeX Live 2026 / Windows 上编译并渲染检查；其他系统尚未实测。确认版面后将 `main.pdf` 复制到 `output/pdf/实验三_Linux启动初始化过程探析_XXX.pdf`。编译中间文件不纳入版本控制。

## Agent 协作与后续提交

Agent 完成源码分析、代码和测试脚本编写、虚拟机命令执行、日志收集及报告排版；用户确定范围、批准变更、观察重启界面并登录桌面。对话记录区分真实截图、原文节选、事后摘要及未覆盖环节，不据此宣称学生已经独立掌握全部实现。

已有个人标题截图；仍建议补充探针设计和故障诊断的关键轮次。报告已补四个原理问答，由 Agent 协助整理，应由本人确认能解释实现和测试边界。建议现场说明：Btrfs 模块如何由 initramfs 加载、systemd 挂载失败为何不等于内核未启动、各服务耗时为何不能简单相加。[AGENTS.md](AGENTS.md) 规定后续编辑与证据维护方式；[SHA-256 清单](docs/evidence-sha256.txt) 可用于校验本次归档工件。首次提交只记录本次整理，不追溯伪造实验时的 Git 历史。
