```mermaid
# 本文件由 vars/topology.yml 自动渲染，请勿手改
# 渲染命令：ansible-playbook site.yml --tags topology
# 输出为 Markdown（含 mermaid 代码块），推到 GitHub 后自动成图
graph TD
    Internet([Internet<br/>外网入口])

    subgraph SG1["IoT"]
        D1["Lumi-Gateway-Floor-1<br/>192.168.50.101"]
        D2["Lumi-Gateway-Floor-2<br/>192.168.50.201"]
        D3["HoneyWell<br/>192.168.50.193"]
        D4["bedside-lamp<br/>192.168.50.246"]
        D5["garage-opener<br/>192.168.50.221"]
        D6["backlit-frame<br/>192.168.50.187"]
    end

    subgraph SG2["云端 · Phase 2"]
        D7["VPS"]
    end

    subgraph SG3["媒体"]
        D8["ESP32-Bathroom<br/>192.168.50.192"]
        D9["ESP32-LivingRoom<br/>192.168.50.114"]
        D10["ESP32-A1S<br/>192.168.50.169"]
        D11["ESP32-Kitchen<br/>192.168.50.147"]
        D12["RPI 播放器<br/>192.168.50.207"]
        D13["Sony TV<br/>192.168.50.220"]
        D14["Xiaoai-X08A<br/>192.168.50.180"]
    end

    subgraph SG4["安防"]
        D15["Camera_Mi_F2<br/>192.168.50.26"]
        D16["Camera-Lumi-Backyard<br/>192.168.50.52"]
        D17["ReoLink-DoorBell<br/>192.168.50.86"]
        D18["stair-closet-camera<br/>192.168.50.109"]
        D19["Camera_Mi_F1<br/>192.168.50.143"]
        D20["Camera-Lumi-Garage<br/>192.168.50.213"]
    end

    subgraph SG5["服务器"]
        D21["QNAP TS-453Bmini<br/>192.168.50.210"]
        D22["LMS<br/>:9000"]
        D21 --- D22
        D23["MariaDB<br/>:3306"]
        D21 --- D23
        D24["Home Assistant<br/>:8123"]
        D21 --- D24
        D25["Homepage<br/>:3000"]
        D21 --- D25
        D26["Uptime Kuma<br/>:3001"]
        D21 --- D26
        D27["TS-110<br/>192.168.50.110"]
    end

    subgraph SG6["终端"]
        D28["Pixel-10-Pro<br/>192.168.50.53"]
        D29["Pixel-7-Pro<br/>192.168.50.253"]
        D30["iPhone-15ProMax<br/>192.168.50.99"]
        D31["Pixel-2-XL<br/>192.168.50.205"]
        D32["iPhone-Moneris<br/>192.168.50.227"]
        D33["iPhone-XS<br/>192.168.50.103"]
        D34["ThinkPad-T14<br/>192.168.50.140"]
        D35["ThinkPad-X230<br/>192.168.50.230"]
        D36["Home-Xiaoxin<br/>192.168.50.195"]
        D37["Lenovo-Pad<br/>192.168.50.160"]
    end

    subgraph SG7["网络基础设施"]
        D38["ASUS TUF Gaming BE6500<br/>192.168.50.1"]
    end

    Internet --> D38
    D38 --> D21
    classDef warn fill:#fef2f2,stroke:#ef4444,color:#991b1b;
```
