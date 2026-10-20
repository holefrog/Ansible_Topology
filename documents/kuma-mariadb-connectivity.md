# Uptime Kuma 无法连接 MariaDB

## 现象

Uptime Kuma 中只有 MariaDB 监控报 `Connection failed`，状态从 `Pending` 变为 `Down`；其他监控正常。家庭网络中的 TV/Kodi 可以正常连接 MariaDB。

MariaDB 容器发布了端口：

```text
0.0.0.0:3306->3306/tcp
```

## 已确认情况

TV/Kodi 可以通过局域网地址访问 MariaDB，说明 MariaDB 对局域网客户端可用。Kuma 也应监控同一个局域网入口 `192.168.50.210:3306`，以验证用户实际依赖的访问路径。

检查时发现两个容器位于不同的 Docker 网络：

- Uptime Kuma 起初只在默认 `bridge` 网络，地址为 `10.0.3.2/24`。
- MariaDB 位于 `mariadb_default` 网络，地址为 `172.29.12.2/22`。

Kuma 最初连接 QNAP 局域网地址 `192.168.50.210:3306` 时超时。QNAP 主机本身使用 `curl telnet://` 测试 `127.0.0.1:3306` 和 `192.168.50.210:3306` 均得到 `Connected to`。因此 MariaDB 端口在宿主机本地可连接，问题范围缩小到 Kuma 容器网络到 QNAP LAN 地址的路径。

LMS 的 HTTP `:9000` 监控正常，不能证明 MariaDB 的 `:3306` 也可达；HTTP 与 Port 监控使用不同协议和端口，但都要建立到目标的 TCP 连接。当前没有 LMS 容器网络配置的检查结果，因此不能据此断言 LMS 使用 host 网络。

## 网络测试

为区分“Docker 网络内部直连”和“局域网地址访问”，Kuma 曾被临时接入 MariaDB 所在的 Docker 网络：

```bash
/share/CACHEDEV1_DATA/.qpkg/container-station/bin/docker network connect mariadb_default uptime-kuma
```

检查结果确认 Kuma 同时加入 `bridge` 和 `mariadb_default`，并取得 `172.29.12.3/22` 地址。随后从 Kuma 容器连接 MariaDB 的 Docker 网络主机名 `mariadb:3306`，测试结果为 `connected`。这只证明容器间直连成功，不能证明局域网目标 `192.168.50.210:3306` 可达。

Kuma 后来断开 `mariadb_default`，恢复原来的 bridge 网络；从该状态再次连接 `192.168.50.210:3306` 仍然超时。结合宿主机本地连接成功，确认故障位于 Kuma bridge 到宿主机 LAN 地址的网络路径上。

## Kuma 监控配置

为了监控和 TV/Kodi 相同的局域网入口，MariaDB 监控应使用 **Port** 类型，目标保持为：

- Hostname：`192.168.50.210`
- Port：`3306`

项目当前在 [roles/uptime_kuma/defaults/main.yml](../roles/uptime_kuma/defaults/main.yml) 中的清单已经是 `192.168.50.210:3306`，无需改成容器内部地址。此外，监控创建脚本对已存在的同名监控只会跳过，不会更新配置。

## 修复方式

让 Kuma 使用 Docker `host` 网络模式，使其通过 QNAP 的网络栈访问局域网地址。项目的 Kuma Ansible 角色现已配置 `network_mode: host`，并清空端口发布配置；Kuma UI 仍在 QNAP 的 `3001` 端口提供服务。MariaDB 监控目标保持 `192.168.50.210:3306`，与 TV/Kodi 使用同一个局域网入口。

需要在 QNAP 上运行 Kuma 部署使配置生效。部署后应确认 Kuma 使用 host 网络，并在 Kuma 中验证 MariaDB 监控恢复。Docker host 模式不使用 `ports` 映射，且共享宿主机网络栈；如果 QNAP 上已有程序占用配置的服务端口，容器会遇到端口冲突。
