# os_lab1_3

操作系统实验三：Linux 启动初始化过程探析。平台为 VMware 中的 Kubuntu 24.04.3 LTS，目标内核为 `6.12.110-oslab3-xxx`。仓库名按提交要求使用 `os_lab1_3`，内容仅包含实验三。

[实验报告 PDF](output/pdf/实验三_Linux启动初始化过程探析_XXX.pdf) · [XeLaTeX 源文件](report/main.tex) · [测试矩阵](docs/test-matrix.md) · [Agent 交互记录](ai-record/README.md)

## 完成情况与证据

运行证据采集于 **2026-09-21**；**2026-10-05** 进行材料整理、报告修订和仓库发布。本次发布没有重新运行虚拟机实验，以下数字均来自保存的原始日志。

| 内容 | 已观察到的结果 | 证据 |
|---|---|---|
| 源码研读、配置和构建 | 6.12.110，成功构建耗时 1:12:32；首轮 BTF 构建失败如实保留 | [构建状态](report/logs/build.status)、[完整日志](report/logs/build.log)、[耗时](report/logs/build-time.txt) |
| 新内核实际启动 | `6.12.110-oslab3-xxx`，Btrfs 根分区可用、PID 1 为 systemd、SSH active | [启动验证](report/logs/boot-verification.txt) |
| emergency mode 排查 | fstab 指向排查时不存在的两个 libvirt 子卷；先备份再修复，重启恢复 | [备份记录](report/logs/fstab-backup.txt)、报告第 6、9 章 |
| 额外设计：内核启动探针 | `/proc/oslab3_boot` 提供开机相对时间、内核版本与状态；可加载/卸载 | [源码](extra-design/oslab3_probe.c)、[手动测试日志](report/logs/extra-design-manual-test.log) |
| 探针启动后检查 | 当次 9 项检查全部 PASS，装载时间为开机后 6557 ms | [测试脚本](tests/test_boot_probe.sh)、[结果](report/logs/extra-design-test.log) |
| 启动性能观测 | 内核 5.890 s + 用户空间 7.305 s；工具报告总计 13.196 s | [性能记录](report/logs/boot-performance.txt)、[原始 SVG](report/figures/boot-analysis.svg) |

个人姓名、学号等保持 `XXX`。**带个人标题的原始对话截图尚未补齐**，目前附有[脱敏文字节选](ai-record/dialogue-excerpts.md)和明确标记的事后摘要。发布仓库不表示课程要求的个人标记和对话证据已经全部完成。

## 文件范围

```text
AGENTS.md                         后续 Agent 的工作约定
README.md                         范围、复现入口、结果和限制
extra-design/                     探针 C 源码、Makefile、安装脚本、加载配置
tests/                            九项检查与启动性能采集脚本
report/main.tex                   报告源文件
report/scripts/                   原实验执行、采集和截图辅助脚本
report/logs/                      原始编译、安装、启动与测试日志及内核配置
report/figures/                   六张实机截图和原始启动时序 SVG
output/pdf/                       一份最终报告 PDF
docs/                            测试矩阵、证据 SHA-256 清单
ai-record/                       对话节选、摘要及截图补充清单
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

## 编译报告

安装含中文支持的 TeX Live、XeLaTeX、Fandol 和 TeX Gyre 字体后，从仓库根目录运行：

```bash
cd report
xelatex -interaction=nonstopmode -halt-on-error main.tex
xelatex -interaction=nonstopmode -halt-on-error main.tex
```

源文件使用 TeX 字体文件名查找，不依赖 Windows 盘符。此次已在 TeX Live 2026 / Windows 上编译并渲染检查；其他系统尚未实测。确认版面后将 `main.pdf` 复制到 `output/pdf/实验三_Linux启动初始化过程探析_XXX.pdf`。编译中间文件不纳入版本控制。

## Agent 协作与后续提交

Agent 完成源码分析、代码和测试脚本编写、虚拟机命令执行、日志收集及报告排版；用户确定范围、批准变更、观察重启界面并登录桌面。对话记录区分原文节选、事后摘要和待补截图，不据此宣称学生已经独立掌握全部实现。

后续补充带姓名/学号标题的对话截图，并由本人检查报告的理解问题、确认能解释实现和测试边界。建议现场说明：Btrfs 模块如何由 initramfs 加载、systemd 挂载失败为何不等于内核未启动、各服务耗时为何不能简单相加。[AGENTS.md](AGENTS.md) 规定后续编辑与证据维护方式；[SHA-256 清单](docs/evidence-sha256.txt) 可用于校验本次归档工件。首次提交只记录本次整理，不追溯伪造实验时的 Git 历史。
