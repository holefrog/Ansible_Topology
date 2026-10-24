<!--
  本文件由 vars/topology.yml 自动渲染，请勿手改
  渲染命令：ansible-playbook site.yml --tags topology
  输出为 Markdown（含 mermaid 代码块），推到 GitHub 后自动成图
-->

```mermaid
flowchart TD
    Internet([Internet<br/>外网入口])

    subgraph SG1["网络基础设施"]
        direction LR
        D1["ASUS TUF Gaming BE6500<br/>192.168.50.1"]
    end

    subgraph SG2["服务器"]
        direction LR
        D2["QNAP TS-453Bmini<br/>192.168.50.210"]
        D3["LMS<br/>:9000"]
        D2 --- D3
        D4["MariaDB<br/>:3306"]
        D2 --- D4
        D5["Home Assistant<br/>:8123"]
        D2 --- D5
        D6["Homepage<br/>:3000"]
        D2 --- D6
        D7["Uptime Kuma<br/>:3001"]
        D2 --- D7
        D8["TS-110<br/>192.168.50.110"]
    end

    subgraph SG3["安防"]
        direction LR
        D9["Camera_Mi_F2<br/>192.168.50.26"]
        D10["Camera-Lumi-Backyard<br/>192.168.50.52"]
        D11["ReoLink-DoorBell<br/>192.168.50.86"]
        D12["stair-closet-camera<br/>192.168.50.109"]
        D13["Camera_Mi_F1<br/>192.168.50.143"]
        D14["Camera-Lumi-Garage<br/>192.168.50.213"]
    end

    subgraph SG4["IoT"]
        direction LR
        D15["Lumi-Gateway-Floor-1<br/>192.168.50.101"]
        D16["Lumi-Gateway-Floor-2<br/>192.168.50.201"]
        D17["HoneyWell<br/>192.168.50.193"]
        D18["bedside-lamp<br/>192.168.50.246"]
        D19["garage-opener<br/>192.168.50.221"]
        D20["backlit-frame<br/>192.168.50.187"]
    end

    subgraph SG5["媒体"]
        direction LR
        D21["ESP32-Bathroom<br/>192.168.50.192"]
        D22["ESP32-LivingRoom<br/>192.168.50.114"]
        D23["ESP32-A1S<br/>192.168.50.169"]
        D24["ESP32-Kitchen<br/>192.168.50.147"]
        D25["RPI 播放器<br/>192.168.50.207"]
        D26["Sony TV<br/>192.168.50.220"]
        D27["Xiaoai-X08A<br/>192.168.50.180"]
    end

    subgraph SG6["终端"]
        direction LR
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

    subgraph SG7["云端 · Phase 2"]
        direction LR
        D38["VPS"]
    end

    Internet --> D1
    D1 --> D2

    %% 垂直约束：保证各分组自上而下逐行排列（一行一条），避免横向拉成过长长条
    SG1 ~~~ SG2
    SG2 ~~~ SG3
    SG3 ~~~ SG4
    SG4 ~~~ SG5
    SG5 ~~~ SG6
    SG6 ~~~ SG7

    classDef warn fill:#fef2f2,stroke:#ef4444,color:#991b1b;
```
