# VM Setup Guide
## SOC Automation Lab 2.0 

---

## Prerequisites

- VirtualBox installed on host machine
- At minimum 16 GB RAM on host (32 GB recommended)
- ISO files downloaded: Ubuntu 24.04, Windows 10, Kali Linux

---

## Step 1 — Create NATNetwork in VirtualBox

1. Open VirtualBox → File → Tools → Network Manager
2. Select NATNetworks tab → Create
3. Name it: `soc-lab-net`
4. IPv4 Prefix: `10.0.2.0/24`
5. Enable DHCP: Yes

---

## Step 2 — Create Splunk VM

- OS: Ubuntu 24.04 Server
- RAM: 8 GB
- CPU: 2 cores
- Disk: 100 GB (minimum — Splunk indexes grow fast)
- Network: Attached to NATNetwork `soc-lab-net`
- Install OpenSSH Server during Ubuntu setup

After install, note IP address: `ip a`

---

## Step 3 — Create Windows 10 VM

- OS: Windows 10 Pro
- RAM: 4–6 GB
- CPU: 2 cores
- Disk: 80 GB
- Network: Attached to NATNetwork `soc-lab-net`
- Enable Remote Desktop after install

---

## Step 4 — Create n8n VM

- OS: Ubuntu 24.04 Server
- RAM: 4 GB
- CPU: 2 cores
- Disk: 50 GB
- Network: Attached to NATNetwork `soc-lab-net`
- Install OpenSSH Server during Ubuntu setup

---

## Step 5 — Import Kali Linux VM

1. Download Kali Linux pre-built VirtualBox image from kali.org
2. File → Import Appliance → select the .ova file
3. Set RAM to 4 GB
4. Network: Attached to NATNetwork `soc-lab-net`

---

## Step 6 — Configure Port Forwarding

In VirtualBox → NATNetwork → soc-lab-net → Port Forwarding:

| Name | Protocol | Host IP | Host Port | Guest IP | Guest Port |
|------|----------|---------|-----------|----------|------------|
| SSH-Splunk | TCP | 127.0.0.1 | 2222 | 10.0.2.15 | 22 |
| SplunkWeb | TCP | 127.0.0.1 | 8000 | 10.0.2.15 | 8000 |
| n8n | TCP | 127.0.0.1 | 5678 | 10.0.2.4 | 5678 |
| SSH-n8n | TCP | 127.0.0.1 | 2223 | 10.0.2.4 | 22 |

---

## Step 7 — Snapshot All VMs

Before installing anything, take a snapshot of each VM:
- Right-click VM → Snapshots → Take Snapshot
- Name: `base-clean`

Repeat after each major phase completion.

---

## IP Address Reference

| VM | Expected IP | Notes |
|----|-------------|-------|
| Splunk VM | 10.0.2.15 | Static or note DHCP-assigned |
| Windows 10 | 10.0.2.1 | Static or note DHCP-assigned |
| n8n VM | 10.0.2.4 | Static or note DHCP-assigned |
| Kali Linux | 10.0.2.3 | Static or note DHCP-assigned |

> If your DHCP assigns different IPs, update `configs/outputs.conf`,
> `configs/docker-compose.yaml`, and your Splunk forwarder settings accordingly.
