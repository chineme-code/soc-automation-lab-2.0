# SOC Automation Lab 2.0
### AI-Assisted Alert Triage | Splunk · n8n · OpenAI · AbuseIPDB · Slack

![Status](https://img.shields.io/badge/Status-Phase%201%20Complete-brightgreen)
![SIEM](https://img.shields.io/badge/SIEM-Splunk-orange)
![Automation](https://img.shields.io/badge/Automation-n8n-blue)
![AI](https://img.shields.io/badge/AI-OpenAI%20GPT--4o-purple)
![License](https://img.shields.io/badge/Use-Educational%20%2F%20Portfolio-lightgrey)

---

## Overview

This project builds a complete, on-premises SOC automation pipeline that ingests Windows endpoint telemetry, detects suspicious activity in Splunk, and routes AI-enriched, analyst-ready alerts into Slack — fully automated through n8n.

It demonstrates how a single analyst can automate ~73% of the first-triage workflow, reducing mean triage time from ~8–12 minutes (manual) to ~45–90 seconds (automated).

> **Ethical notice:** All adversary simulation activity is performed exclusively against lab VMs in an isolated NATNetwork environment. No real malware, no production systems, no real credentials.

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│           VirtualBox NATNetwork (10.0.2.0/24)   │
│                                                  │
│  ┌──────────────┐      ┌──────────────────────┐  │
│  │  Kali Linux  │─────▶│   Windows 10 VM      │  │
│  │  10.0.2.3    │      │   10.0.2.1           │  │
│  │  (Adversary  │      │   Sysmon + Forwarder  │  │
│  │   Emulation) │      └──────────┬───────────┘  │
│  └──────────────┘                 │               │
│                            port 9997              │
│                                   ▼               │
│                      ┌────────────────────────┐   │
│                      │    Splunk VM           │   │
│                      │    10.0.2.15           │   │
│                      │    SIEM · Detections   │   │
│                      └──────────┬─────────────┘   │
│                                 │                  │
│                         Webhook (POST)             │
│                                 ▼                  │
│                      ┌────────────────────────┐   │
│                      │    n8n VM              │   │
│                      │    10.0.2.4            │   │
│                      │    Automation Engine   │   │
│                      └──┬─────────────────┬───┘   │
└─────────────────────────┼─────────────────┼───────┘
                          │                 │
                    OpenAI API         AbuseIPDB API
                    (GPT-4o-mini)      (IP Reputation)
                          │                 │
                          └────────┬────────┘
                                   ▼
                              Slack #alerts
                         (Analyst Notification)
```

---

## Lab Environment

| VM | OS | IP Address | RAM | Role |
|---|---|---|---|---|
| Windows 10 | Windows 10 Pro | 10.0.2.1 | 4–6 GB | Monitored endpoint |
| Splunk VM | Ubuntu 24.04 | 10.0.2.15 | 8 GB | SIEM + alerting |
| n8n VM | Ubuntu 24.04 | 10.0.2.4 | 4 GB | Automation engine |
| Kali Linux | Kali 2024.x | 10.0.2.3 | 4 GB | Adversary emulation |

**Host machine:** VirtualBox with NATNetwork. Port forwarding rules:

| Name | Host Port | Guest IP | Guest Port | Purpose |
|---|---|---|---|---|
| SSH | 2222 | 10.0.2.15 | 22 | SSH into Splunk VM |
| SplunkWeb | 8000 | 10.0.2.15 | 8000 | Splunk browser UI |
| n8n | 5678 | 10.0.2.4 | 5678 | n8n browser UI |

---

## Project Phases

- [x] **Phase 1** — VM setup, Splunk, n8n, brute-force detection, AI triage, Slack ✅
- [ ] **Phase 2** — Sysmon, multi-vector detections, Atomic Red Team validation
- [ ] **Phase 3** — TheHive case management, Shuffle SOAR, machine isolation playbook

---

## Quick Start

### Prerequisites
- VirtualBox (or VMware)
- 16–32 GB RAM on host machine
- OpenAI API account (minimum $5 credit)
- AbuseIPDB account (free tier)
- Slack workspace with admin access

### 1. Clone this repo
```bash
git clone https://github.com/YOUR_USERNAME/soc-automation-lab-2.0.git
cd soc-automation-lab-2.0
```

### 2. Set up VMs
Create four VMs in VirtualBox using a shared NATNetwork (10.0.2.0/24). See `docs/vm-setup-guide.md` for detailed steps.

### 3. Install Splunk
```bash
# On Splunk Ubuntu VM (SSH in via port 2222)
ssh -p 2222 take-code@127.0.0.1

# Download and install
sudo dpkg -i splunk-<version>-linux-amd64.deb

# Start and create admin account
cd /opt/splunk/bin
sudo -u splunk bash
./splunk start

# Enable boot start
sudo ./splunk enable boot-start -user splunk
```

Then in Splunk Web (http://127.0.0.1:8000):
- Settings → Forwarding and Receiving → Configure Receiving → Port: **9997**
- Settings → Indexes → New Index → Name: **take-code**
- Apps → Find More Apps → Install: **Splunk Add-on for Microsoft Windows**

### 4. Configure Windows Forwarder
Install Splunk Universal Forwarder on the Windows VM, pointing to `10.0.2.15:9997`. Copy `configs/inputs.conf` to:
```
C:\Program Files\SplunkUniversalForwarder\etc\system\local\inputs.conf
```
Then restart the SplunkForwarder service as Local System Account.

### 5. Deploy n8n
```bash
# On n8n Ubuntu VM
mkdir n8n-compose && cd n8n-compose
cp /path/to/configs/docker-compose.yaml .

# Fix permissions and start
sudo chown -R 1000:1000 n8n_data/
sudo docker-compose up -d
```
Access at http://127.0.0.1:5678

### 6. Import n8n Workflow
In n8n, go to **Settings → Import Workflow** and import `configs/n8n-workflow.json`. Add your credentials:
- OpenAI API key
- AbuseIPDB API key  
- Slack Bot OAuth token

### 7. Load Splunk Detections
In Splunk Web → Search & Reporting, run each `.spl` file from the `detections/` folder and save as a scheduled alert with the n8n webhook URL.

---

## Repository Structure

```
soc-automation-lab-2.0/
├── README.md                        # This file
├── configs/
│   ├── inputs.conf                  # Splunk Universal Forwarder config
│   ├── outputs.conf                 # Splunk forwarder output (indexer target)
│   └── docker-compose.yaml          # n8n Docker Compose config
├── detections/
│   ├── brute_force_4625.spl         # Failed logon detection
│   ├── suspicious_process.spl       # Sysmon EventID 1 — process execution
│   ├── suspicious_network.spl       # Sysmon EventID 3 — network connections
│   └── powershell_abuse.spl         # EventID 4104 — PowerShell ScriptBlock
├── prompts/
│   └── ai_triage_system_prompt.txt  # GPT-4o system prompt for SOC triage
├── scripts/
│   ├── enable_ps_logging.ps1        # Enable PowerShell ScriptBlock logging
│   ├── install_sysmon.ps1           # Sysmon install + SwiftOnSecurity config
│   └── test_brute_force.sh          # Kali — safe RDP failed auth generator
├── docs/
│   ├── vm-setup-guide.md            # Detailed VM creation walkthrough
│   ├── splunk-configuration.md      # Splunk setup reference
│   ├── n8n-workflow-guide.md        # n8n workflow build guide
│   ├── hitl-scoring.md              # Human-in-the-loop analysis
│   └── mitre-mapping.md             # MITRE ATT&CK coverage table
└── .github/
    └── DISCLAIMER.md                # Ethical use and lab-only disclaimer
```

---

## Detection Use Cases

| Detection | SPL File | Event Source | MITRE Technique | Severity |
|---|---|---|---|---|
| Brute Force / Failed Logons | `brute_force_4625.spl` | Security (4625) | T1110 | HIGH |
| Suspicious Process Execution | `suspicious_process.spl` | Sysmon EventID 1 | T1059 | HIGH |
| Suspicious Network Connection | `suspicious_network.spl` | Sysmon EventID 3 | T1071 | HIGH |
| PowerShell Abuse | `powershell_abuse.spl` | PowerShell 4104 | T1059.001 | MEDIUM–CRITICAL |

---

## n8n Workflow

```
Webhook (Splunk POST)
    │
    ▼
Set Node — Normalize Fields
    │
    ▼
IF Node — Is source IP external?
    ├── YES → AbuseIPDB HTTP Request Tool
    └── NO  → Skip enrichment
         │
         ▼
OpenAI GPT-4o — AI Triage
(System prompt: SOC analyst persona)
(User prompt: alert context + enrichment data)
         │
         ▼
IF Node — Severity Router
    ├── CRITICAL/HIGH → #alerts-critical
    └── MEDIUM/LOW   → #alerts-review
         │
         ▼
Slack Node — Send formatted message
```

---

## AI Triage Output Format

Every alert produces a structured Slack message in this format:

```
SOC Alert Triage
Alert Name:   <value>
Host:         <value>
User:         <value>
Source IP:    <value>
Severity:     HIGH
MITRE ATT&CK: TA0006 Credential Access / T1110 Brute Force
Summary:      <2–4 sentence plain-English description>
IOC Enrichment:
  - AbuseIPDB Score: 100/100
  - Country: Romania
  - Category: SSH Brute Force
Recommended Actions:
  1. Verify whether source IP is known or authorized
  2. Check for successful logon (EventCode 4624) following the failures
  3. Block source IP at perimeter if confirmed malicious
Confidence:   High — external IP with confirmed abuse history
```

---

## Human-in-the-Loop Scoring

| Step | Automated | Human Required |
|---|---|---|
| Receive and parse alert | ✅ | |
| IP reputation lookup | ✅ | |
| MITRE ATT&CK mapping | ✅ | |
| Plain-English summary | ✅ | |
| Priority assignment | ✅ | |
| Alert routing to Slack | ✅ | |
| True/false positive confirmation | | ✅ |
| Containment authorization | | ✅ |
| Escalation decision | | ✅ |

**Result:** ~73% of first-triage steps automated. Analyst focus reserved for decisions requiring business context and containment authority.

---

## Adversary Emulation (Lab-Safe)

All simulation activity targets lab VMs only on the isolated NATNetwork.

| Scenario | Tool | Event Generated | Detection Triggered |
|---|---|---|---|
| RDP brute force | Hydra / manual | EventCode 4625 | Brute Force |
| Port scan | nmap | Sysmon EventID 3 | Suspicious Network |
| Process discovery | Atomic Red Team T1057 | Sysmon EventID 1 | Suspicious Process |
| Encoded PowerShell | Manual / ART T1059.001 | EventID 4104 | PowerShell Abuse |

---

## Skills Demonstrated

- SIEM configuration and log ingestion (Splunk)
- Windows event log and Sysmon telemetry forwarding
- SPL detection query development with MITRE ATT&CK mapping
- Webhook-based alert routing and automation (n8n)
- AI prompt engineering for structured SOC triage (OpenAI GPT-4o)
- REST API integration (AbuseIPDB, Slack)
- Docker Compose deployment on Ubuntu
- Controlled adversary emulation for detection validation
- Human-in-the-loop automation design

---

## Certifications & Context

Built by **Chinemelum Umealajekwu** 
- Cybersecurity Analyst Intern.  
- MS Cybersecurity & Business Analytics, University of New Mexico (GPA: 4.09)  
- CompTIA Security+ | CompTIA CySA+
- With inspiration from MyDFIR YouTube channel. Please go and support him and the hard work he's putting in
---

## Disclaimer

This project is for **educational and portfolio purposes only**. All activity was performed in an isolated, self-owned virtual machine lab environment. Nothing in this repository should be used against systems you do not own or have explicit written authorization to test. See `.github/DISCLAIMER.md` for full terms.
