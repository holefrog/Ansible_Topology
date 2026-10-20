# 容器资源限制

Homepage 和 Uptime Kuma 由 Ansible 的 `community.docker.docker_container` 模块部署，不通过 Docker Compose 管理。两个容器都配置了 CPU 和内存上限：

| 容器 | 默认内存上限 | 默认 CPU 上限 | 变量定义 |
| --- | --- | --- | --- |
| Homepage | 512 MiB | 0.5 核 | `homepage_memory_limit`、`homepage_cpus_limit` |
| Uptime Kuma | 512 MiB | 0.5 核 | `kuma_memory_limit`、`kuma_cpus_limit` |

变量分别定义在 `roles/homepage/defaults/main.yml` 和 `roles/uptime_kuma/defaults/main.yml`，可由更高优先级的 Ansible 变量覆盖。

## 限制含义与初始值依据

- `memory` 是容器可用内存的硬上限，不是预留量。达到限制时，容器内进程可能被 Linux OOM killer 终止。
- `cpus` 是容器最多可使用的 CPU 数量。`0.5` 表示最多约半个逻辑 CPU 的计算能力，不代表预留半个 CPU。
- Homepage 当前用于呈现家庭服务、设备状态和配置的仪表板；Uptime Kuma 当前维护少量 HTTP、TCP 和 Ping 监控项，间隔为 60 秒。以各 512 MiB 和 0.5 CPU 作为轻量工作负载的起始上限。
- Homepage 和 Uptime Kuma 的官方项目文档没有为所有部署场景规定统一的 CPU/内存规格，因此这些数值是本项目的运维起始值，不是厂商最低要求或容量保证。监控项增加、历史数据增长或负载变化后，应以 QNAP 上的实测峰值调整。

## 应用与检查

在项目根目录运行对应 playbook，让 Ansible 将限制同步到容器：

```bash
ansible-playbook site.yml -e @secrets.yml --tags homepage
ansible-playbook site.yml -e @secrets.yml --tags kuma
```

在 QNAP 上使用 Container Station 自带的 Docker CLI 检查配置和运行用量（实际 CLI 路径按设备安装情况调整）：

```bash
docker inspect --format '{{.HostConfig.Memory}} {{.HostConfig.NanoCpus}}' homepage
docker inspect --format '{{.HostConfig.Memory}} {{.HostConfig.NanoCpus}}' uptime-kuma
docker stats --no-stream homepage uptime-kuma
```

`docker inspect` 输出的内存单位为字节；512 MiB 对应 `536870912`，0.5 CPU 对应 `500000000` NanoCPUs。`docker stats` 显示当前使用量，需在正常使用和峰值场景下观察。若服务被 OOM 终止、CPU 长期被节流或负载明显增长，应提高对应的角色默认变量并重新部署。

资源限制需要 Docker Engine 和宿主机内核支持。应用后应通过 `docker inspect` 确认限制确实写入；如果 QNAP 的 Container Station / Docker 版本不支持或未应用限制，应以设备上的检查结果为准。

## 参考

- [Ansible `community.docker.docker_container` 模块文档](https://docs.ansible.com/ansible/latest/collections/community/docker/docker_container_module.html)
- [Docker Engine：容器资源限制](https://docs.docker.com/engine/containers/resource_constraints/)
- [Homepage 安装文档](https://gethomepage.dev/installation/)
- [Uptime Kuma 项目文档](https://github.com/louislam/uptime-kuma)
