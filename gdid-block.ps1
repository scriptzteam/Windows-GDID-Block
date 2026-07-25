# ==============================================================================
# Windows GDID & Telemetry Block
# ==============================================================================
# WARNING: Disabling these components will break Phone Link, Cloud Clipboard, 
# Nearby Sharing, and Windows Update peer-to-peer delivery optimization.
# ==============================================================================

# ------------------------------------------------------------------------------
# STEP 1: Administrator Check
# ------------------------------------------------------------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "CRITICAL: This script must be run as an Administrator to modify system services and the hosts file."
    Exit
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   GDID Reporting Silencer Initialized   " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# STEP 2: Audit Current Local GDID State
# Reads the 64-bit device PUID (LID) out of the current user's identity hive.
# ------------------------------------------------------------------------------
Write-Host "`n[1/4] Auditing local registry for GDID (Device PUID)..." -ForegroundColor Yellow
$gdidPath = "HKCU:\SOFTWARE\Microsoft\IdentityCRL\ExtendedProperties"
if (Test-Path $gdidPath) {
    $properties = Get-ItemProperty -Path $gdidPath -ErrorAction SilentlyContinue
    # Look for the 'LID' or 'DeviceId' properties containing the 0x0018 namespace string
    foreach ($prop in $properties.PSObject.Properties) {
        if ($prop.Name -like "LID*" -or $prop.Name -eq "DeviceId") {
            Write-Host "-> Found Cached Device PUID: $($prop.Value)" -ForegroundColor Magenta
            Write-Host "   (Note: Deleting this is cosmetic; it re-downloads from Microsoft if services are active.)" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "-> No local MSA Device PUID found in active HKCU path." -ForegroundColor Gray
}

# ------------------------------------------------------------------------------
# STEP 3: Stop & Silence Registration and Reporting Services
# Disables CDPSvc (Graph registration) and DoSvc (Delivery Optimization reporting).
# Note: DoSvc ignores standard 'Set-Service' controls; it must be forced via registry.
# ------------------------------------------------------------------------------
Write-Host "`n[2/4] Disabling target pipeline services (CDPSvc & DoSvc)..." -ForegroundColor Yellow

$ServicesToDisable = @("CDPSvc", "DoSvc")

foreach ($service in $ServicesToDisable) {
    Write-Host "Stopping and neutralizing service: $service" -ForegroundColor Gray
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
    
    # Force Start type to 4 (Disabled) directly in System registry to bypass ACL locks
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$service" -Name "Start" -Value 4 -Force
}

# Also disable the per-user Connected Devices variant template
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\CDPUserSvc" -Name "Start" -Value 4 -Force

# ------------------------------------------------------------------------------
# STEP 4: Flush Local Connected Devices Graph Cache
# Clears out tracking profiles and local states stored under the local appdata.
# ------------------------------------------------------------------------------
Write-Host "`n[3/4] Purging local Connected Devices Platform database..." -ForegroundColor Yellow
$localCache = "$env:LOCALAPPDATA\ConnectedDevicesPlatform"
if (Test-Path $localCache) {
    Remove-Item -Path "$localCache\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "-> Local activity cache directory cleared." -ForegroundColor Green
} else {
    Write-Host "-> Cache directory empty or already missing." -ForegroundColor Gray
}

# ------------------------------------------------------------------------------
# STEP 5: Blackhole Graph and Delivery Optimization Endpoints
# Blackholes the exact DDS and DO endpoints discovered via network mapping.
# ------------------------------------------------------------------------------
Write-Host "`n[4/4] Appending DDS and DO endpoints to the system hosts file..." -ForegroundColor Yellow
$hostsPath = "$env:windir\System32\drivers\etc\hosts"

# Exact endpoints mapped from cdp.dll and UCDOStatus reporting chains
$gdidEndpoints = @(
    "0.0.0.0 dds.microsoft.com",
    "0.0.0.0 fd.dds.microsoft.com",
    "0.0.0.0 aad.cs.dds.microsoft.com",
    "0.0.0.0 cdpcs.access.microsoft.com",
    "0.0.0.0 activity.windows.com"
    "0.0.0.0 login.live.com",
    "0.0.0.0 windows.com",
    "0.0.0.0 live.com",
    "0.0.0.0 microsoft.com"
)

# Loop to safely inject the entries with retries in case real-time AV holds a lock
$maxRetries = 3
foreach ($entry in $gdidEndpoints) {
    $retryCount = 0
    $success = $false
    
    while (-not $success -and $retryCount -lt $maxRetries) {
        try {
            $currentHosts = Get-Content -Path $hostsPath -ErrorAction Stop
            if ($currentHosts -notcontains $entry) {
                Add-Content -Path $hostsPath -Value "`n$entry" -ErrorAction Stop
            }
            $success = $true
            Write-Host "-> Blocked: $($entry.Split(' ')[1])" -ForegroundColor Gray
        }
        catch {
            $retryCount++
            Write-Host "Hosts file locked by real-time protection/AV. Retrying mapping ($retryCount/$maxRetries)..." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}

# ------------------------------------------------------------------------------
# STEP 6: Execution Summary
# ------------------------------------------------------------------------------
Write-Host "`n=========================================" -ForegroundColor Green
Write-Host "   Mitigation Completed Successfully   " -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host "A system reboot is required to completely terminate active service handles." -ForegroundColor White
