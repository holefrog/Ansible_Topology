# AGENTS.md — Ansible_Topology

## 项目定位

家庭网络 + VPS 可视化的**上层** Ansible 项目。

- 本项目独立管理 Uptime Kuma（监控告警、设备元数据与统一入口）的容器部署，
  以及从唯一的设备清单动态同步 Kuma 监控项并渲染 Mermaid 拓扑图。
- **架构决策**：Homepage 已彻底退役，由 Uptime Kuma 原生覆盖并替代（详见 README.md 架构演进说明）。

## 目录说明

- `site.yml` — 本项目总入口，只运行本项目 roles（Kuma 部署与拓扑渲染）
- `check_status.yml` — 检查 Uptime Kuma 容器运行状态与拓扑输出文件
- `inventory/hosts.yml` — 本项目的主机 inventory
- `vars/topology.yml` — **唯一的设备清单**（真相源），见下
- `roles/uptime_kuma` — 部署 Kuma 容器 + 从 topology.yml 动态同步监控项与档案卡片（`tasks/monitors.yml`，幂等；账号密码走 secrets.yml）
- `roles/topology` — 从 topology.yml 渲染 topology.mmd，推 Git 后 GitHub 自动成图
- `secrets.yml` — 路由器/QNAP 账号密码，**永不提交**（见 .gitignore）
- `keys/` — 放 SSH 私钥（如 `keys/asus_be6500`），**永不提交**（见 .gitignore）；公钥 `.pub` 可随仓库走

## 铁律

1. 加设备/改 IP/改备注只改 `vars/topology.yml`，拓扑图与监控项全自动同步，不手写输出文件。
2. 改完跑 `site.yml` 验证：`http://192.168.50.210:3001`（Kuma）。
3. 不确定的 IP/MAC 写占位并标注"待补充"，不编造。
4. 本项目只部署 Uptime Kuma 并渲染拓扑；Docker/Container Station 由 QNAP 系统提供，不由本项目安装。

## 环境与常用命令

- 路由器：ASUS TUF BE6500，`192.168.50.1`，SSH 端口 **22122**（非默认 22），账号密码来自 secrets.yml
- 拉设备表：`ssh Dong@192.168.50.1 "cat /var/lib/misc/dnsmasq.leases"`
- QNAP：TS-453Bmini，`192.168.50.210`，Container Station 跑容器
- HA 虚拟机：`192.168.50.236`（QNAP Virtualization Station，bridge 模式）— 只读，不动
- 运行：`ansible-playbook site.yml -e @secrets.yml` 或运行 `./apply.sh`
- 只跑监控同步：`ansible-playbook site.yml -e @secrets.yml --tags kuma-monitors`

## 分期

- Phase 1：内网（本仓库全部内容）。
- Phase 2：VPS（GCP×2 + RackNerd + Oracle）。数据源是本地 Ansible 项目的 inventory，
  反代映射从 nginx/caddy 模板解析。到时 Kuma 加 "VPS" 分组，topology.mmd 展开 Phase 2 子图，不新增工具。
