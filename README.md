# Ansible_Topology

家庭网络 + VPS 可视化 Ansible 项目，独立部署本项目的 Homepage、Uptime Kuma，并渲染网络拓扑。

**铁律**：`vars/topology.yml` 是唯一真相源。Homepage 配置和 Mermaid 拓扑都由它渲染，永远不要手改输出文件。

本项目直接创建 Homepage 和 Uptime Kuma 容器，不安装 Docker。部署前需确保 QNAP 已安装并启动 Container Station，且 Ansible 登录用户可以访问 Docker daemon；playbook 会在部署容器前检查这些条件。

## 目录结构

```ini
site.yml                  # 总入口：运行本项目的 Homepage、Uptime Kuma 和 topology roles
ansible.cfg               # inventory/roles 路径、关闭 host key 检查
requirements.yml          # community.docker
inventory/hosts.yml       # 本项目使用的主机 inventory
vars/topology.yml         # ★ 唯一真相源：全部设备
keys/                     # 路由器 SSH 私钥（git 排除）
secrets.yml               # 密码（git 排除，见下）
apply.sh                  # 交互式部署入口，按选项调用 site.yml playbook
roles/
  homepage/               # 统一服务入口 :3000（渲染 services.yaml.j2 → 起容器）
  uptime_kuma/            # 可用性监控 :3001（host 网络，监控项由代码幂等创建）
  topology/               # 渲染 topology.mmd.j2 → output/topology.md（推 GitHub 成图）
```

## 首次部署

```bash
ansible-galaxy collection install -r requirements.yml
# 创建 secrets.yml（见下方格式）
# 将 keys/asus_be6500.pub 添加到路由器 ~/.ssh/authorized_keys
./apply.sh
```

`apply.sh` 是交互式封装，会根据菜单选择调用本项目的 `site.yml` playbook：

| 选项 | 操作 |
| --- | --- |
| 1 | 部署 Homepage、Uptime Kuma，并渲染拓扑 |
| 2 | 只部署 Homepage |
| 3 | 只部署 Uptime Kuma |
| 4 | 部署 Homepage 和 Uptime Kuma |
| 5 | 只渲染拓扑 |
| 6 | 检查服务与拓扑状态 |

也可跳过菜单直接运行 playbook，例如：

```bash
ansible-playbook site.yml -e @secrets.yml --tags viz       # 本项目全部功能
ansible-playbook site.yml -e @secrets.yml --tags homepage  # 只部署 Homepage
ansible-playbook site.yml -e @secrets.yml --tags kuma      # 只部署 Uptime Kuma
ansible-playbook site.yml -e @secrets.yml --tags topology  # 只渲染拓扑
ansible-playbook check_status.yml -e @secrets.yml          # 检查容器与服务状态
```

`secrets.yml` 格式：

```yaml
qnap_ssh_user: "你的 QNAP SSH 用户"
qnap_ssh_password: "你的 QNAP SSH 密码"
kuma_admin_user: "admin"       # Kuma 首次打开 :3001 时创建的管理员账号
kuma_admin_password: "xxxx"
```

QNAP SSH 端口使用 `51000`；`inventory/hosts.yml` 会把上述凭据映射到 Ansible SSH 连接变量。

验证：打开 `http://192.168.50.210:3000`（Homepage）、`http://192.168.50.210:3001`（Kuma，首次打开设账号密码）。

## 日常：加/改设备

1. 改 `vars/topology.yml`（只改这一个文件）
2. 运行 `./apply.sh`，选择部署选项；若只改拓扑则选择 5
3. `git add output/topology.md && git commit -m "update" && git push`（GitHub 自动成图）

## Kuma 监控项（代码建，幂等）

Uptime Kuma 使用 Docker `host` 网络模式，直接使用 QNAP 的网络栈；访问 QNAP 局域网地址时不依赖容器到宿主机的端口转发。Kuma Web UI 仍通过 `http://192.168.50.210:3001` 访问。host 模式下不配置 Docker 端口映射。

`roles/uptime_kuma/defaults/main.yml` 里的 `kuma_monitors` 清单，部署 Kuma 时调 API 自动建，已存在的按名字跳过：

| 目标 | 类型 | 地址 |
| --- | --- | --- |
| LMS | HTTP | 192.168.50.210:9000 |
| Home Assistant | HTTP | 192.168.50.236:8123 |
| MariaDB | TCP | 192.168.50.210:3306 |
| 路由器 / QNAP / HA | Ping | .1 / .210 / .236 |

加监控：往 `kuma_monitors` 加一行，重跑部署（`./apply.sh` 选 3，或 `ansible-playbook site.yml -e @secrets.yml --tags kuma-monitors`）。

手机（Pixel/iPhone）不进监控：休眠断 Wi-Fi 会误报。
