# ============================================================
# enable_ps_logging.ps1
# SOC Automation Lab 2.0 | Chinemelum Osholake
#
# Run as Administrator on the Windows 10/11 VM
# Enables ScriptBlock and Module logging so EventID 4104/4103
# are generated for the PowerShell abuse detection
# ============================================================

Write-Host "[*] Enabling PowerShell ScriptBlock Logging..." -ForegroundColor Cyan

# Enable ScriptBlock Logging (EventID 4104)
$sbPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
New-Item -Path $sbPath -Force | Out-Null
Set-ItemProperty -Path $sbPath -Name "EnableScriptBlockLogging" -Value 1
Set-ItemProperty -Path $sbPath -Name "EnableScriptBlockInvocationLogging" -Value 1

Write-Host "[+] ScriptBlock Logging enabled" -ForegroundColor Green

# Enable Module Logging (EventID 4103)
$modPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging"
New-Item -Path $modPath -Force | Out-Null
Set-ItemProperty -Path $modPath -Name "EnableModuleLogging" -Value 1

$modNamesPath = "$modPath\ModuleNames"
New-Item -Path $modNamesPath -Force | Out-Null
Set-ItemProperty -Path $modNamesPath -Name "*" -Value "*"

Write-Host "[+] Module Logging enabled" -ForegroundColor Green

# Enable Transcription (optional — writes PS sessions to log files)
$transPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription"
New-Item -Path $transPath -Force | Out-Null
Set-ItemProperty -Path $transPath -Name "EnableTranscripting" -Value 1
Set-ItemProperty -Path $transPath -Name "OutputDirectory" -Value "C:\PSTranscripts"

Write-Host "[+] Transcription enabled -> C:\PSTranscripts" -ForegroundColor Green

# Verify settings
Write-Host "`n[*] Verification:" -ForegroundColor Cyan
Get-ItemProperty -Path $sbPath  -ErrorAction SilentlyContinue
Get-ItemProperty -Path $modPath -ErrorAction SilentlyContinue

Write-Host "`n[+] Done. Test by running: powershell -EncodedCommand RwBlAHQALQBQAHIAbwBjAGUAcwBzAA==" -ForegroundColor Green
Write-Host "    (decodes to: Get-Process — triggers EventID 4104 in Splunk)" -ForegroundColor Yellow
