# ⚡ Windows System Intelligence Reporter

---

## 📌 Project Overview

A production-ready PowerShell automation script that performs **deep Windows system introspection** using modern CIM (Common Information Model) and legacy WMI (Windows Management Instrumentation) queries. It collects hardware and software telemetry across a running Windows machine and generates dual-format reports — a structured **JSON** data file and an interactive **HTML dashboard** — without requiring any third-party dependencies.

Built for IT administrators, DevOps engineers, and system auditors who need fast, repeatable, professional-grade system snapshots.

---

## 🎯 Key Features

| Feature | Details |
|---|---|
| ⚙️ Hardware Profiling | CPU, RAM, Disks, Network Adapters |
| 🖥️ System Details | OS version, uptime, hostname, architecture |
| 📄 JSON Export | Machine-readable structured output |
| 🌐 HTML Report | Interactive, collapsible sections |
| 🔍 CIM/WMI Queries | Modern CIM-first with WMI fallback |
| 🚫 Zero Dependencies | Pure PowerShell — no external modules |

---

## 📊 Data Collected

### Hardware Components

```
┌─────────────────────────────────────────────────────┐
│                  SYSTEM SNAPSHOT                    │
├──────────────────┬──────────────────────────────────┤
│ CPU              │ Name, Cores, Threads, Clock Speed │
│ Memory (RAM)     │ Total, Available, Usage %         │
│ Disk Drives      │ Label, Size, Free Space, FS Type  │
│ Network Adapters │ Name, MAC, IP, Status, Speed      │
│ System Info      │ Hostname, OS, Build, Uptime       │
│ BIOS             │ Manufacturer, Version, Date       │
│ Motherboard      │ Manufacturer, Model, Serial       │
└──────────────────┴──────────────────────────────────┘
```

### CIM Queries Used

```powershell
# CPU Information
Get-CimInstance -ClassName Win32_Processor

# Physical Memory
Get-CimInstance -ClassName Win32_PhysicalMemory

# Logical Disks
Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3"

# Network Adapters
Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled=$true"

# Operating System
Get-CimInstance -ClassName Win32_OperatingSystem

# BIOS
Get-CimInstance -ClassName Win32_BIOS

# Baseboard (Motherboard)
Get-CimInstance -ClassName Win32_BaseBoard
```

---

## 📂 Repository Structure

```
windows-system-reporter/
│
├── SystemReporter.ps1          # Main automation script
├── output/
│   ├── SystemReport.json       # Structured JSON output
│   └── SystemReport.html       # Interactive HTML dashboard

├── README.md
└── LICENSE
```

---

## 🚀 Getting Started

### Prerequisites

- Windows 10, Windows 11, or Windows Server 2016+
- PowerShell 5.1 or PowerShell 7+
- Run as **Administrator** for full hardware access

### Run the Script

```powershell
# 1. Clone the repository
git clone https://github.com/shruthisriram16/windows-system-reporter.git
cd windows-system-reporter

# 2. Allow script execution (run once as Admin)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 3. Run the reporter
.\SystemReporter.ps1
```

Reports are saved automatically to the `output/` folder.

---

## 📄 Output Formats

### JSON Report

Structured, machine-readable output — ideal for feeding into monitoring pipelines, CMDB tools, or further automation.

```json
{
  "GeneratedAt": "2025-05-27T10:45:00",
  "Hostname": "DESKTOP-XYZ123",
  "OS": "Microsoft Windows 11 Pro",
  "CPU": {
    "Name": "Intel(R) Core(TM) i7-12700K",
    "Cores": 12,
    "Threads": 20,
    "MaxClockSpeedMHz": 3600
  },
  "Memory": {
    "TotalGB": 32,
    "AvailableGB": 18.4,
    "UsagePercent": 42.5
  },
  "Disks": [
    {
      "Drive": "C:",
      "Label": "System",
      "TotalGB": 476.8,
      "FreeGB": 210.3,
      "FileSystem": "NTFS"
    }
  ],
  "NetworkAdapters": [
    {
      "Description": "Intel(R) Wi-Fi 6 AX201",
      "MACAddress": "A4:C3:F0:XX:XX:XX",
      "IPAddress": "192.168.1.105",
      "Status": "Connected"
    }
  ]
}
```

### HTML Report

A self-contained, styled HTML file with **collapsible sections** for each hardware category — no server required, opens directly in any browser.

```
┌─────────────────────────────────────────┐
│  🖥️  Windows System Report              │
│  Generated: 2025-05-27 10:45:00         │
│  Host: DESKTOP-XYZ123                   │
├─────────────────────────────────────────┤
│  ▼  CPU Information                     │
│     Intel Core i7-12700K | 12C / 20T   │
├─────────────────────────────────────────┤
│  ▶  Memory                              │  ← Click to expand
├─────────────────────────────────────────┤
│  ▶  Disk Drives                         │
├─────────────────────────────────────────┤
│  ▶  Network Adapters                    │
├─────────────────────────────────────────┤
│  ▶  BIOS & Motherboard                  │
└─────────────────────────────────────────┘
```

The HTML report is fully self-contained — all CSS and JavaScript is embedded inline, so it works offline with no dependencies.

---

## 🔧 Script Architecture

```powershell
SystemReporter.ps1
│
├── 1. Data Collection Layer
│   ├── Invoke-CimQuery()        # Wrapper with error handling
│   ├── Get-CPUInfo()
│   ├── Get-MemoryInfo()
│   ├── Get-DiskInfo()
│   ├── Get-NetworkInfo()
│   └── Get-SystemInfo()
│
├── 3. Export Layer
│   ├── Export-JsonReport()      # Serializes to formatted JSON
│   └── Export-HtmlReport()     # Generates interactive HTML
│
└── 4. Entry Point
    └── Main execution block with timestamp and output paths
```

---


## 🔮 Future Roadmap

- [ ] Multi-machine remote execution via `Invoke-Command`
- [ ] Scheduled Task integration for periodic snapshots
- [ ] Email report delivery via `Send-MailMessage`
- [ ] CSV export option for spreadsheet import
- [ ] GPU information via DirectX diagnostics
- [ ] Compare two snapshots and highlight hardware changes

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

