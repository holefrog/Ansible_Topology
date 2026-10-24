# 容器资源限制

本项目容器由 Ansible 的 `community.docker.docker_container` 模块部署，不通过 Docker Compose 管理。

| 容器 | 默认内存上限 | 默认 CPU 上限 | 变量定义 | 说明 |
| --- | --- | --- | --- | --- |
| Uptime Kuma | 512 MiB | 0.5 核 | `kuma_memory_limit`、`kuma_cpus_limit` | 现行唯一常驻容器（监控+元数据入口） |
| ~~Homepage~~ | ~~512 MiB~~ | ~~0.5 核~~ | 已退役 | 功能已被 Uptime Kuma 完整替代，已下线 |

变量定义在 `roles/uptime_kuma/defaults/main.yml`，可由更高优先级的 Ansible 变量覆盖。

## 限制含义与初始值依据

- `memory` 是容器可用内存的硬上限，不是预留量。达到限制时，容器内进程可能被 Linux OOM killer 终止。
- `cpus` 是容器最多可使用的 CPU 数量。`0.5` 表示最多约半个逻辑 CPU 的计算能力，不代表预留半个 CPU。
- Uptime Kuma 运行在 QNAP 宿主机，通过 Docker `host` 网络模式每 60 秒对局域网设备进行轻量探测。配置 512 MiB 和 0.5 CPU 能够充裕承载 30+ 监控项并长期平稳运行。
- 退役 Homepage 后，QNAP 宿主机常态节省了 512 MiB 内存及伴随的容器进程开销。

## 应用与检查

在项目根目录运行 playbook 同步限制：

```bash
ansible-playbook site.yml -e @secrets.yml --tags kuma
```

在 QNAP 上检查配置与用量：

```bash
docker inspect --format '{{.HostConfig.Memory}} {{.HostConfig.NanoCpus}}' uptime-kuma
docker stats --no-stream uptime-kuma
```

`docker inspect` 输出的内存单位为字节；512 MiB 对应 `536870912`，0.5 CPU 对应 `500000000` NanoCPUs。

## 参考

- [Ansible `community.docker.docker_container` 模块文档](https://docs.ansible.com/ansible/latest/collections/community/docker/docker_container_module.html)
- [Docker Engine：容器资源限制](https://docs.docker.com/engine/containers/resource_constraints/)
- [Uptime Kuma 项目文档](https://github.com/louislam/uptime-kuma)
