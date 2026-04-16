# ============================================================
# install_sysmon.ps1
# SOC Automation Lab 2.0 | Chinemelum Osholake
#
# Run as Administrator on the Windows 10/11 VM
# Downloads Sysmon + SwiftOnSecurity config and installs
# ============================================================

Write-Host "[*] Starting Sysmon installation..." -ForegroundColor Cyan

# Create tools directory
$toolsDir = "C:\Tools\Sysmon"
New-Item -ItemType Directory -Path $toolsDir -Force | Out-Null

# Download Sysmon
Write-Host "[*] Downloading Sysmon from Sysinternals..." -ForegroundColor Cyan
Invoke-WebRequest `
    -Uri "https://download.sysinternals.com/files/Sysmon.zip" `
    -OutFile "$toolsDir\Sysmon.zip"
Expand-Archive -Path "$toolsDir\Sysmon.zip" -DestinationPath $toolsDir -Force
Write-Host "[+] Sysmon downloaded" -ForegroundColor Green

# Download SwiftOnSecurity config
Write-Host "[*] Downloading SwiftOnSecurity Sysmon config..." -ForegroundColor Cyan
Invoke-WebRequest `
    -Uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" `
    -OutFile "$toolsDir\sysmonconfig.xml"
Write-Host "[+] Config downloaded" -ForegroundColor Green

# Install Sysmon with config
Write-Host "[*] Installing Sysmon..." -ForegroundColor Cyan
Set-Location $toolsDir
.\Sysmon64.exe -accepteula -i sysmonconfig.xml

# Verify
$svc = Get-Service -Name Sysmon64 -ErrorAction SilentlyContinue
if ($svc.Status -eq "Running") {
    Write-Host "[+] Sysmon64 is RUNNING" -ForegroundColor Green
} else {
    Write-Host "[!] Sysmon64 may not be running — check manually: sc query Sysmon64" -ForegroundColor Yellow
}

Write-Host "`n[*] Test: run 'whoami' in cmd and check Splunk for Sysmon EventID 1" -ForegroundColor Cyan
Write-Host "    index=take-code sourcetype=`"XmlWinEventLog:Sysmon`" EventCode=1" -ForegroundColor Yellow
