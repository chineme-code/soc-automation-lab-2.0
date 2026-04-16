#!/bin/bash
# ============================================================
# test_brute_force.sh
# SOC Automation Lab 2.0
#
# Run on Kali Linux VM ONLY
# Generates safe, controlled failed RDP authentication attempts
# against the lab Windows VM to trigger Splunk brute-force detection
#
# TARGET: Lab Windows VM only (10.0.2.1) — NEVER use against
#         systems you do not own or have written authorization for
# ============================================================

TARGET_IP="10.0.2.1"
TARGET_USER="take-code"
WORDLIST="/tmp/lab_test_passwords.txt"

echo "[*] SOC Automation Lab — Brute Force Telemetry Generator"
echo "[*] Target: $TARGET_IP (lab Windows VM only)"
echo "[!] For authorized lab use only"
echo ""

# Create a wordlist of obviously wrong passwords — lab use only
cat > $WORDLIST << 'EOF'
wrongpass1
wrongpass2
wrongpass3
wrongpass4
wrongpass5
wrongpass6
wrongpass7
wrongpass8
testpassword
labpassword
EOF

echo "[*] Created test wordlist at $WORDLIST"

# Check hydra is available
if ! command -v hydra &> /dev/null; then
    echo "[*] Installing hydra..."
    sudo apt install hydra -y
fi

echo "[*] Starting controlled RDP authentication test..."
echo "[*] This will generate EventCode 4625 entries in Splunk"
echo ""

# Run hydra against lab Windows VM — these will all fail (intentional)
hydra -l "$TARGET_USER" -P "$WORDLIST" rdp://"$TARGET_IP" -t 1 -W 2

echo ""
echo "[+] Test complete. Check Splunk for EventCode 4625 events:"
echo "    index=take-code EventCode=4625 | stats count by host user"
echo ""
echo "[*] Cleaning up wordlist..."
rm -f $WORDLIST
echo "[+] Done"
