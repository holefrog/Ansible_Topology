#!/bin/bash

# 切换到脚本所在目录，确保 Ansible 使用本项目的配置和 inventory。
cd "$(dirname "$0")" || exit 1

echo "=========================================================================="
echo "请选择要执行的本项目任务："
echo "1. 🚀 本项目全量部署（Homepage + Uptime Kuma + 拓扑渲染）"
echo "2. 🏠 部署/更新 Homepage"
echo "3. 📈 部署/更新 Uptime Kuma"
echo "4. 🖥️  部署/更新 Homepage 和 Uptime Kuma"
echo "5. 🗺️  仅渲染拓扑"
echo "6. 🔍 检查服务与拓扑状态"
echo "0. ❌ 退出（默认）"
echo "=========================================================================="
read -r -p "请输入选项 [0]: " choice

case "$choice" in
    1)
        echo ">>> 开始部署本项目全部角色..."
        # viz 标签运行本项目的全部 roles。
        ansible-playbook site.yml -e @secrets.yml --tags viz
        ;;
    2)
        echo ">>> 开始部署 Homepage..."
        ansible-playbook site.yml -e @secrets.yml --tags homepage
        ;;
    3)
        echo ">>> 开始部署 Uptime Kuma..."
        ansible-playbook site.yml -e @secrets.yml --tags kuma
        ;;
    4)
        echo ">>> 开始部署 Homepage 和 Uptime Kuma..."
        ansible-playbook site.yml -e @secrets.yml --tags homepage,kuma
        ;;
    5)
        echo ">>> 开始渲染拓扑..."
        ansible-playbook site.yml -e @secrets.yml --tags topology
        ;;
    6)
        echo ">>> 正在检查本项目服务与拓扑状态..."
        ansible-playbook check_status.yml -e @secrets.yml
        ;;
    0|*)
        echo ">>> 已退出。"
        exit 0
        ;;
esac

result=$?
if [[ $result -eq 0 ]]; then
    echo ">>> 任务完成！"
else
    echo ">>> 部署失败，ansible-playbook 退出码：$result"
fi
exit "$result"