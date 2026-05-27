<#
.SYNOPSIS
    System Configuration Reporting Tool

.DESCRIPTION
    This PowerShell script collects comprehensive system information including hardware
    and software configuration details. It exports the data to both JSON and HTML formats
    with a professional, collapsible HTML report interface.

.AUTHOR
    Shruthi Sriram

.VERSION
    1.0

.DATE
    February 16, 2026

.NOTES
    Requires PowerShell 5.1 or higher
    Requires administrative privileges for some WMI/CIM queries
    Compatible with Windows 10/11 and Windows Server 2016+

.FUNCTIONS
    get-myconfig      - Collects system configuration data
    get-myconfigjson  - Exports configuration to JSON format
    get-myconfightml  - Generates professional HTML report with collapsible sections

.EXAMPLE
    # Collect system information
    $config = get-myconfig
    
    # Export to JSON
    get-myconfigjson -data $config -path ".\config.json"
    
    # Generate HTML report
    get-myconfightml -data $config -path ".\system_report.html"

#>

#function to get system configuration 
function get-myconfig
{
 $cpu  = Get-CimInstance win32_processor|
         Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed |
         Foreach-Object { "Name= $($_.Name), Cores=$($_.NumberOfCores), Threads=$($_.NumberofLogicalProcessors),Clockspeed= $($_.MaxClockSpeed)"}

 $audio = Get-CimInstance Win32_SoundDevice |
          Select-Object ProductName,Manufacturer|
          ForEach-Object {"ProductName=$($_.ProductName),Manufacturer=$($_.Manufacturer),"}

 $video = Get-CimInstance Win32_VideoController |
          Select-Object Name,DriverVersion, VideoProcessor|
          ForEach-Object {"Name=$($_.Name),Processor=$($_.VideoProcessor), Driver=$($_.DriverVersion)"}

 $os = Get-CimInstance Win32_OperatingSystem |
       Select-Object Caption, Version, Manufacturer|
       ForEach-Object {"caption=$($_.Caption) Version =$($_.Version),Manufacturer=$($_.Manufacturer)"}

 $motherboard = Get-CimInstance Win32_BaseBoard |
                Select-Object Manufacturer, Product, SerialNumber |
                ForEach-Object {"Manufacturer=$($_.Manufacturer), Product=$($_.Product), Serial=$($_.SerialNumber)"}

 $bios = Get-CimInstance Win32_BIOS |
         Select-Object Manufacturer, SMBIOSBIOSVersion, ReleaseDate |
         ForEach-Object {"Manufacturer=$($_.Manufacturer), BIOS=$($_.SMBIOSBIOSVersion), Date=$($_.ReleaseDate)"}
            

 $network = Get-CimInstance Win32_NetworkAdapterConfiguration |
            Where-Object { $_.IPEnabled } |
            Select-Object Description, MACAddress, IPAddress |
            ForEach-Object{"Name=$($_.Description), MAC=$($_.MACAddress), IP=$($_.IPAddress)"}

 $memory = Get-CimInstance Win32_PhysicalMemory |
           Select-Object Manufacturer, Capacity, Speed, DeviceLocator |
           ForEach-Object {"Manufacturer=$($_.Manufacturer), Capacity=$([math]::Round($_.Capacity/1GB,2))GB, Speed=$($_.Speed)MHz, Slot=$($_.DeviceLocator)"}

 $totalMemory = Get-CimInstance Win32_ComputerSystem |
                Select-Object -ExpandProperty TotalPhysicalMemory
 $totalMemoryGB = [math]::Round($totalMemory/1GB,2)

 $disk = Get-CimInstance Win32_DiskDrive |
         Select-Object Model, Size, MediaType, InterfaceType |
         ForEach-Object {"Model=$($_.Model), Size=$([math]::Round($_.Size/1GB,2))GB, Type=$($_.MediaType), Interface=$($_.InterfaceType)"}

 $diskPartitions = Get-CimInstance Win32_LogicalDisk |
                   Where-Object { $_.DriveType -eq 3 } |
                   Select-Object DeviceID, VolumeName, Size, FreeSpace |
                   ForEach-Object {"Drive=$($_.DeviceID), Label=$($_.VolumeName), Size=$([math]::Round($_.Size/1GB,2))GB, Free=$([math]::Round($_.FreeSpace/1GB,2))GB"}

 $computerSystem = Get-CimInstance Win32_ComputerSystem |
                   Select-Object Name, Manufacturer, Model, Domain, Workgroup, UserName |
                   ForEach-Object {"Name=$($_.Name), Manufacturer=$($_.Manufacturer), Model=$($_.Model), Domain=$($_.Domain), Workgroup=$($_.Workgroup), User=$($_.UserName)"}

 $os2 = Get-CimInstance Win32_OperatingSystem
 $lastBootUpTime = $os2.LastBootUpTime
 $uptime = (Get-Date) - $lastBootUpTime
 $uptimeString = "Days=$($uptime.Days), Hours=$($uptime.Hours), Minutes=$($uptime.Minutes)"

 $timeZone = Get-TimeZone |
             ForEach-Object {"TimeZone=$($_.DisplayName), Id=$($_.Id), Offset=$($_.BaseUtcOffset)"}

 $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

 $battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
 if ($battery) {
     $battery = $battery | Select-Object Name, EstimatedChargeRemaining, BatteryStatus |
                ForEach-Object {"Name=$($_.Name), Charge=$($_.EstimatedChargeRemaining)%, Status=$($_.BatteryStatus)"}
 } else {
     $battery = "No battery detected (Desktop PC or battery information unavailable)"
 }

 $monitor = Get-CimInstance WmiMonitorID -Namespace root\wmi -ErrorAction SilentlyContinue |
            ForEach-Object {
                $manufacturer = [System.Text.Encoding]::ASCII.GetString($_.ManufacturerName -ne 0)
                $name = [System.Text.Encoding]::ASCII.GetString($_.UserFriendlyName -ne 0)
                "Manufacturer=$manufacturer, Name=$name"
            }
 if (-not $monitor) { $monitor = "Monitor information unavailable" }

return [PSCustomObject]@{
        CPU              = $cpu
        Audio            = $audio
        Video            = $video
        OS               = $os
        Motherboard      = $motherboard
        BIOS             = $bios
        Network          = $network
        Memory           = $memory
        TotalMemory      = "$totalMemoryGB GB"
        Disk             = $disk
        DiskPartitions   = $diskPartitions
        ComputerSystem   = $computerSystem
        SystemUptime     = $uptimeString
        TimeZone         = $timeZone
        CurrentUser      = $currentUser
        Battery          = $battery
        Monitor          = $monitor
   }
}

#function to save it to json file
function get-myconfigjson
{
  param(
    $data,
    [string]$path)
  $data|convertTo-json -depth 10|out-file -FilePath $path -Encoding UTF8
}

#function to convert it to html and print in table format with collapsible sections
function get-myconfightml{
 param(
   $data,
   [string]$path)

#start html with modern styling and collapsible sections
$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Configuration Report</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f5f5;
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 2px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .header {
            background: #2c3e50;
            color: white;
            padding: 30px;
            border-bottom: 3px solid #34495e;
        }
        .header h1 {
            font-size: 2em;
            margin-bottom: 8px;
            font-weight: 400;
        }
        .header p {
            font-size: 0.95em;
            color: #bdc3c7;
        }
        .content {
            padding: 20px;
        }
        .section {
            margin-bottom: 10px;
            border: 1px solid #ddd;
            background: white;
        }
        .section-header {
            background: #f8f9fa;
            color: #2c3e50;
            padding: 14px 20px;
            cursor: pointer;
            display: flex;
            justify-content: space-between;
            align-items: center;
            user-select: none;
            border-bottom: 1px solid #ddd;
        }
        .section-header:hover {
            background: #e9ecef;
        }
        .section-header h2 {
            font-size: 1.1em;
            font-weight: 600;
            color: #2c3e50;
        }
        .toggle-icon {
            font-size: 1.2em;
            color: #6c757d;
            transition: transform 0.2s ease;
        }
        .section-header.active .toggle-icon {
            transform: rotate(180deg);
        }
        .section-content {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.3s ease;
            background: #ffffff;
        }
        .section-content.active {
            max-height: 2000px;
        }
        .section-body {
            padding: 20px;
            background: #fafafa;
        }
        .info-item {
            padding: 10px 12px;
            margin-bottom: 6px;
            background: white;
            border-left: 3px solid #5a6268;
            font-size: 0.9em;
            line-height: 1.6;
            color: #333;
        }
        .info-item:last-child {
            margin-bottom: 0;
        }
        .footer {
            text-align: center;
            padding: 20px;
            color: #6c757d;
            font-size: 0.85em;
            background: #f8f9fa;
            border-top: 1px solid #ddd;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>System Configuration Report</h1>
            <p>Author: Shruthi Sriram</p>
            <p>Generated on: $(Get-Date -Format 'MMMM dd, yyyy - HH:mm:ss')</p>
        </div>
        <div class="content">
"@

# Define section friendly names
$sectionInfo = @{
    'CPU' = 'Processor (CPU)'
    'Audio' = 'Audio Devices'
    'Video' = 'Graphics Card'
    'OS' = 'Operating System'
    'Motherboard' = 'Motherboard'
    'BIOS' = 'BIOS Information'
    'Network' = 'Network Adapters'
    'Memory' = 'RAM Modules'
    'TotalMemory' = 'Total System Memory'
    'Disk' = 'Physical Disks'
    'DiskPartitions' = 'Disk Partitions'
    'ComputerSystem' = 'Computer System Information'
    'SystemUptime' = 'System Uptime'
    'TimeZone' = 'Time Zone'
    'CurrentUser' = 'Current User'
    'Battery' = 'Battery Status'
    'Monitor' = 'Monitor Information'
}

foreach ($prop in $data.PSObject.Properties) {
    $name = $prop.Name
    $value = $prop.Value
    
    $displayName = if ($sectionInfo.ContainsKey($name)) { $sectionInfo[$name] } else { $name }
    
    $html += @"
            <div class="section">
                <div class="section-header" onclick="toggleSection(this)">
                    <h2>$displayName</h2>
                    <span class="toggle-icon">▼</span>
                </div>
                <div class="section-content">
                    <div class="section-body">
"@
    
    if ($value -is [array]) {
        foreach ($item in $value) {
            $formattedItem = $item -replace ',', '<br>'
            $html += "                        <div class='info-item'>$formattedItem</div>`n"
        }
    } else {
        $formattedValue = $value -replace ',', '<br>'
        $html += "                        <div class='info-item'>$formattedValue</div>`n"
    }
    
    $html += @"
                    </div>
                </div>
            </div>
"@
}

$html += @"
        </div>
        <div class="footer">
            <p>System Configuration Report | PowerShell Script | $(Get-Date -Format 'yyyy')</p>
        </div>
    </div>
    <script>
        function toggleSection(header) {
            header.classList.toggle('active');
            const content = header.nextElementSibling;
            content.classList.toggle('active');
        }
        
        // Open first section by default
        document.addEventListener('DOMContentLoaded', function() {
            const firstHeader = document.querySelector('.section-header');
            if (firstHeader) {
                toggleSection(firstHeader);
            }
        });
    </script>
</body>
</html>
"@

    $html | Out-File -FilePath $path -Encoding UTF8
}



               
                   

