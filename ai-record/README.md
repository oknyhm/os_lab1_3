# Agent 交互证据整理说明

截至 2026-10-05，用户尚未截取对话。当前附有 [原文节选](dialogue-excerpts.md) 和
[事后整理摘要](interaction-summary.md)，均非完整平台导出，也不替代带个人信息标题的原始截图。
公开仓库按授权先提交现有材料，截图在补齐后另行提交。

提交前将当前对话标题改为：

`姓名-学号-操作系统实验三-Linux启动初始化过程探析`

建议保留四组截图，并保证标题栏可见：

1. 配置免密 SSH 与确认 Agent 能进入虚拟机；
2. 第一次内核编译在 BTF 阶段失败，以及关闭可选 BTF 后重编译；
3. 新内核首次启动进入 emergency mode，定位到陈旧的 libvirt/fstab 项；
4. 备份并修复 fstab、二次重启、验证新内核和 SSH 正常。
5. 启动探针设计、手动卸载/加载及重启后的九项测试。

不要截入包含登录密码的消息，也不要公开 SSH 私钥或完整
`authorized_keys`。截图文件建议命名为：

- `01-ssh-agent-access.png`
- `02-btf-build-diagnosis.png`
- `03-emergency-mode-diagnosis.png`
- `04-final-boot-verification.png`
- `05-boot-probe-design-test.png`

## 对应关系

| 对话阶段 | 代码或脚本 | 运行证据 |
|---|---|---|
| SSH 配置 | Agent 远程执行记录 | `report/logs/environment.txt` |
| BTF 诊断 | `report/scripts/rebuild-kernel.sh` | `report/logs/build-attempt1.log`、`build.log` |
| 启动异常诊断 | `report/scripts/fix-stale-libvirt-mounts.sh` | `report/logs/fstab-backup.txt` |
| 最终验证 | `report/scripts/collect-boot-verification.sh` | `report/logs/boot-verification.txt` |
| 启动探针 | `extra-design/oslab3_probe.c`、`tests/test_boot_probe.sh` | `report/logs/extra-design-test.log` |

截图应来自实际会话，不重画界面，不把本摘要渲染成图后标成原始对话。报告的个人信息继续使用 XXX，
填写真实个人信息和补齐截图均由实验者在提交课程前确认。
