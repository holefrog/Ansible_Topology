# Ansible_Topology

家庭网络 + VPS 可视化 Ansible 项目：管理 Uptime Kuma 统一监控与元数据看板，并自动渲染局域网 Mermaid 拓扑图。

**铁律**：`vars/topology.yml` 是唯一真相源。所有监控项（IP、类型、MAC、备注、分组）和 Mermaid 拓扑都由它统一驱动，永远不要手改输出文件。

---

## 架构演进：为什么淘汰 Homepage、全面改用 Uptime Kuma？

本项目最初同时部署了 **Homepage**（仪表板大屏）与 **Uptime Kuma**（状态监控）。但在实际生产实践中，发现双容器架构存在严重的技术缺陷与功能重叠，现已**全面退役 Homepage**，由 Uptime Kuma 统一承接，核心原因如下：

### 1. 根治冷启动丢包与休眠假死（Flapping / Cold-Start Drop）
- **Homepage 的缺陷**：Homepage 是无状态（Stateless）按需探测机制。每次用户在浏览器打开页面时，Node.js 后端瞬间向内网所有设备发送单次并发 ping（`-c 1 -w 2`，无重试）。
- **局域网物理现实**：Linux（QNAP 宿主机）ARP 缓存表超时（约 60 秒）后会变为 `STALE` 并被内核 GC 垃圾回收；Wi-Fi IoT 设备（温控器、Zigbee 网关、台灯）常态处于 802.11 DTIM 低功耗省电休眠。
- **导致的假死**：打开 Homepage 瞬间，大量瞬时并发请求引发 ARP 广播泛洪与 2.4GHz Wi-Fi 信道竞争，IoT 设备的第一个唤醒 ICMP 包极易超时或丢包，导致 7×24 小时正常工作的智能家居设备在 Homepage 上大面积变红（显示 DOWN），必须频繁刷新才恢复，严重影响监控信任度。
- **Uptime Kuma 的解决方式**：Kuma 采用 Docker `host` 网络模式常驻运行，每 60 秒定时探测（配置了 `maxretries: 3` 重试防抖）。它不仅自身不会误报，还像一个“局域网保鲜泵”，让 QNAP 内核 ARP 缓存表始终保持活跃（`REACHABLE`），彻底杜绝了设备因休眠而丢包的问题。

### 2. Uptime Kuma 原生覆盖并大幅超越 Homepage
- **元数据档案卡片**：Kuma 的 `Description` 字段原生支持富文本 Markdown。系统从 `vars/topology.yml` 自动提取设备的连接方式、地址类型、MAC 地址、详细备注，并为带 Web 界面的设备自动生成 `[🔗 打开管理后台]` 快捷链接，完全取代了 Homepage 的卡片信息展示。
- **左侧列表一览无余**：监控项命名统一采用 `设备名 (IP)` 格式（如 `HoneyWell (192.168.50.193)`），不用点击即可在侧边栏一扫看清所有内网 IP 分配。
- **树状目录折叠**：Kuma 原生支持 Monitor Group（组），在侧边栏自动按 `网络与服务器`、`IoT 设备`、`安防监控`、`媒体设备`、`终端设备` 折叠收纳，并实时汇总各组设备的在线率。
- **历史趋势与告警**：Homepage 只能看单点瞬间切片；Kuma 拥有 24 小时/30 天可用率曲线、响应耗时监控，并原生支持 Telegram、邮件、Webhook 故障告警。
- **状态大屏（Status Page）**：如需大屏卡片式概览，Kuma 内置了 `/status` 状态页功能，可直接向内网发布精美的状态大屏。

### 3. 架构精简与资源降本（YAGNI 原则）
- QNAP NAS 减少一个常驻容器，节省 512 MiB 内存及后台轮询开销。
- 真正闭环了“**单一真相源**”原则：仅维护 `vars/topology.yml` 这一个文件，拓扑图与监控项全自动同步，无需再维护 Homepage 的 `services.yaml` 映射。

---

## 目录结构

```ini
site.yml                  # 总入口：部署 Uptime Kuma 与渲染拓扑（自动清理退役的 Homepage）
ansible.cfg               # inventory/roles 路径、关闭 host key 检查
requirements.yml          # community.docker 依赖
inventory/hosts.yml       # QNAP 宿主机 inventory（SSH 端口 51000）
vars/topology.yml         # ★ 唯一真相源：全部局域网与 VPS 设备清单
keys/                     # 路由器 SSH 私钥（git 排除）
secrets.yml               # 密码凭据（git 排除，见下）
apply.sh                  # 交互式运维脚本，按选项调用 playbook
roles/
  uptime_kuma/            # 可用性监控 :3001（host 网络，由 topology.yml 动态同步）
  topology/               # 渲染 topology.mmd.j2 → output/topology.md（推 GitHub 自动成图）
output/
  topology.md             # 渲染出的 Mermaid 拓扑图文档
```

---

## 首次部署与运行

```bash
ansible-galaxy collection install -r requirements.yml
# 创建 secrets.yml（见下方格式）
./apply.sh
```

`apply.sh` 是交互式运维脚本，提供清晰的菜单操作：

| 选项 | 操作 |
| :--- | :--- |
| **1** | 🚀 本项目全量部署（Uptime Kuma 监控 + 拓扑渲染） |
| **2** | 📈 部署/更新 Uptime Kuma（含监控项与元数据同步） |
| **3** | 🗺️ 仅渲染拓扑（输出到 `output/topology.md`） |
| **4** | 🔍 检查服务与拓扑状态 |
| **0** | ❌ 退出 |

也可跳过菜单直接运行 Ansible 命令：

```bash
ansible-playbook site.yml -e @secrets.yml --tags viz           # 全量部署
ansible-playbook site.yml -e @secrets.yml --tags kuma          # 只部署/更新 Kuma 容器与监控项
ansible-playbook site.yml -e @secrets.yml --tags kuma-monitors # 只同步监控项与元数据卡片
ansible-playbook site.yml -e @secrets.yml --tags topology      # 只渲染 Mermaid 拓扑
ansible-playbook check_status.yml -e @secrets.yml              # 检查服务状态
```

`secrets.yml` 格式：

```yaml
qnap_ssh_user: "你的 QNAP SSH 用户"
qnap_ssh_password: "你的 QNAP SSH 密码"
kuma_admin_user: "admin"       # Kuma 首次打开 :3001 时创建的管理员账号
kuma_admin_password: "xxxx"
```

验证访问：打开 `http://192.168.50.210:3001`（Kuma Web 控制台）。

---

## 日常运维：加设备 / 改 IP / 改备注

1. 修改 `vars/topology.yml`（**只需改这一个文件**，其他文件勿动）。
2. 执行 `./apply.sh`，按需选择选项 1（全量）或选项 2（仅更新监控）。
3. 提交拓扑变动：
   ```bash
   git add vars/topology.yml output/topology.md
   git commit -m "feat: add new device"
   git push
   ```
   GitHub 页面将自动以 Mermaid 渲染最新网络拓扑图。
