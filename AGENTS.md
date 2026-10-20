# AGENTS.md — Ansible_Topology

## 项目定位

家庭网络 + VPS 可视化的**上层** Ansible 项目。

- 本项目独立管理 Homepage（统一入口）、Uptime Kuma（监控报警）的容器部署，
  以及从设备清单渲染 Homepage 配置和 Mermaid 拓扑图。

## 目录说明

- `site.yml` — 本项目总入口，只运行本项目 roles
- `check_status.yml` — 检查 Homepage/Uptime Kuma 容器运行状态与拓扑输出文件
- `inventory/hosts.yml` — 本项目的主机 inventory
- `vars/topology.yml` — **唯一的设备清单**（真相源），见下
- `roles/homepage` — 部署 homepage 容器 + 从 topology.yml 渲染 services.yaml
- `roles/uptime_kuma` — 部署 kuma 容器（监控项第一版手动建，API 自动建以后再说）
- `roles/topology` — 从 topology.yml 渲染 topology.mmd，推 Git 后 GitHub 自动成图
- `secrets.yml` — 路由器/QNAP 账号密码，**永不提交**（见 .gitignore）
- `keys/` — 放 SSH 私钥（如 `keys/asus_be6500`），**永不提交**（见 .gitignore）；公钥 `.pub` 可随仓库走

## 铁律

1. 加设备/改 IP 只改 `vars/topology.yml`，不手写 services.yaml 和 topology.mmd。
2. 改完跑 `site.yml` 验证：`http://192.168.50.210:3000`（Homepage）、`:3001`（Kuma）。
3. 不确定的 IP/MAC 写占位并标注"待补充"，不编造。
4. 本项目只部署 Homepage、Uptime Kuma 并渲染拓扑；Docker/Container Station 由 QNAP 系统提供，不由本项目安装。

## 环境与常用命令

- 路由器：ASUS TUF BE6500，`192.168.50.1`，SSH 端口 **22122**（非默认 22），账号密码来自 secrets.yml
- 拉设备表：`ssh Dong@192.168.50.1 "cat /var/lib/misc/dnsmasq.leases"`
- QNAP：TS-453Bmini，`192.168.50.210`，Container Station 跑容器
- HA 虚拟机：`192.168.50.236`（QNAP Virtualization Station，bridge 模式）— 只读，不动
- 运行：`ansible-playbook site.yml -e @secrets.yml`
- 只跑某部分：`ansible-playbook site.yml --tags homepage`

## 分期

- Phase 1：内网（本仓库全部内容）。
- Phase 2：VPS（GCP×2 + RackNerd + Oracle）。数据源是本地 Ansible 项目的 inventory，
  反代映射从 nginx/caddy 模板解析。到时 Homepage 加 "VPS" 分组，topology.mmd 展开 Phase 2 子图，不新增工具。
