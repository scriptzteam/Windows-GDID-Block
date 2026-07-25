# 🖕 🛑 Windows-GDID-Block

> ⚠️ **Honest disclaimer up front:** this tool does **not** erase your GDID and does
> **not** make you anonymous. The GDID lives on Microsoft's servers, tied to your
> Microsoft Account, the moment you sign in. `Windows-GDID-Block` stops your machine from
> *re-registering and reporting* it — it cannot undo what Microsoft already has. For
> real privacy on sensitive work, the only reliable answer is NOT to depend on Windows.

A precise, lightweight PowerShell script designed to target, silence, and block the Windows **Global Device Identifier (GDID)** and its associated tracking pipeline.

> **What is the GDID?** The GDID is a persistent, 64-bit device-level identity token minted server-side by Microsoft. It anchors to your Windows installation and continuously syncs your device telemetry, cross-device graphs, and activity tracking—even across strict IP rotations or VPN usage.

---

## ⚠️ Important Side Effects
Because this script stops the background registration loops, applying it **will break the following Windows features**:
*   📱 **Phone Link** & Cross-Device Syncing
*   📋 **Cloud Clipboard** (History sync across devices)
*   📡 **Nearby Sharing** / AirDrop-like features
*   ⚡ **Windows Update Peer-to-Peer Optimization**

---

## 🛠️ What the Script Does

The script executes a targeted 4-stage block rather than blindly breaking Windows activation or stability:

1.  🔍 **Audits the Local Registry:** Locates your current active 64-bit hardware-associated Passport Unique ID (`LID`/`DeviceId`).
2.  🚫 **Disables Core Infrastructure:** Stops and permanently disables the Connected Devices Platform Service (`CDPSvc`, `CDPUserSvc`) and Delivery Optimization (`DoSvc`) through direct registry overrides.
3.  🧹 **Purges Local Cache:** Completely deletes the local tracking databases hidden under `AppData\Local\ConnectedDevicesPlatform`.
4.  🕳️ **Blackholes Network Endpoints:** Injects a strict mapping loop into your system `hosts` file to block communication with Microsoft's Device Directory Service (`dds.microsoft.com`), Activity graphs, and underlying authentication domains.

---

## 🚀 Quick Launch (Run from Web)

To bypass restricted environments (like PowerShell ISE) or standard execution policy blocks, run one of the options below.

### Option A: Direct In-Line Execution
Open an **Elevated (Administrator) PowerShell** window and copy-paste this line directly.

```
Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://raw.githubusercontent.com/scriptzteam/Windows-GDID-Block/refs/heads/main/gdid-block.ps1 | iex
```

or

```
powershell -NoProfile -ExecutionPolicy Bypass -Command "https://raw.githubusercontent.com/scriptzteam/Windows-GDID-Block/refs/heads/main/gdid-block.ps1 | iex"
```

Option B: External Console Spawn

If you are locked inside a constrained shell or text editor console, use this command to automatically spin up a fresh, true administrative window to handle the execution:

```
Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm 'https://raw.githubusercontent.com/scriptzteam/Windows-GDID-Block/refs/heads/main/gdid-block.ps1' | iex`"" -Verb RunAs
```

🔄 Applying the Changes

    Run the script using one of the quick launch strings above.

    Watch the terminal logs verify each step successfully.

    Reboot your PC. A full system restart is required to drop active system service hooks and load the modified registry configurations.

📝 Disclaimer & Credits

This tool is intended strictly for user privacy curation and systems research.
Inspired by the core structural research findings inside the community-driven gdid disclosures.
