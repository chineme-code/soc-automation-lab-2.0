# MITRE ATT&CK Coverage Map
## SOC Automation Lab 2.0 | Chinemelum 

---

## Detections by Tactic

| Detection | Tactic | Technique ID | Technique Name | Data Source |
|-----------|--------|-------------|----------------|-------------|
| Brute Force | TA0006 Credential Access | T1110 | Brute Force | Windows Security Log (4625) |
| Suspicious Process | TA0002 Execution | T1059 | Command and Scripting Interpreter | Sysmon EventID 1 |
| Suspicious Network | TA0011 Command & Control | T1071 | Application Layer Protocol | Sysmon EventID 3 |
| PowerShell Abuse | TA0002 Execution | T1059.001 | PowerShell | PowerShell EventID 4104 |

---

## Tactic Coverage Summary

| Tactic | ID | Covered |
|--------|----|---------|
| Initial Access | TA0001 | Partial (brute force covers credential-based access) |
| Execution | TA0002 | ✅ Yes (process + PowerShell detections) |
| Persistence | TA0003 | Phase 2 (Sysmon registry/startup detections planned) |
| Privilege Escalation | TA0004 | Phase 2 |
| Defense Evasion | TA0005 | Partial (encoded PowerShell detection) |
| Credential Access | TA0006 | ✅ Yes (brute force detection) |
| Discovery | TA0007 | Phase 2 (Atomic Red Team T1057, T1082) |
| Lateral Movement | TA0008 | Phase 2 |
| Collection | TA0009 | Phase 2 |
| Command & Control | TA0011 | ✅ Yes (suspicious network detection) |
| Exfiltration | TA0010 | Phase 2 |
| Impact | TA0040 | Phase 2 |

---

## Atomic Red Team Test Mapping (Phase 2)

| ART Test | MITRE ID | Validates Detection |
|----------|----------|---------------------|
| T1059.001 — Test 1 | PowerShell | powershell_abuse.spl |
| T1057 — Process Discovery | T1057 | suspicious_process.spl |
| T1082 — System Info Discovery | T1082 | suspicious_process.spl |
| T1016 — Network Config Discovery | T1016 | suspicious_network.spl |
| T1110.001 — Password Guessing | T1110.001 | brute_force_4625.spl |
