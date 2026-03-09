function Get-OsInfo {
    $os = Get-CimInstance Win32_OperatingSystem
    [PSCustomObject]@{
        OSName   = $os.Caption
        Version  = $os.Version
        Uptime   = (Get-Date) - $os.LastBootUpTime
        Computer = $env:COMPUTERNAME
    }
}

function Get-DiskInfo {
    Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
    Select-Object DeviceID,
                  @{Name="TotalGB";Expression={[math]::Round($_.Size/1GB,2)}},
                  @{Name="FreeGB";Expression={[math]::Round($_.FreeSpace/1GB,2)}}
}

function Get-TopProcesses {
    Get-Process |
    Sort-Object CPU -Descending |
    Select-Object -First 10 Name, CPU,
@{Name="MemoryMB";Expression={[math]::Round($_.WS / 1MB,2)}}
}

function Get-NetworkInfo {
    Get-CimInstance Win32_NetworkAdapterConfiguration |
    Where-Object {$_.IPEnabled} |
    Select-Object Description,
    @{Name="IPv6";Expression={
        ($_.IPAddress | Where-Object { $_ -like "*:*" }) -join ", "
    }}
}

$osInfo = Get-OsInfo
$diskInfo = Get-DiskInfo
$topProcesses = Get-TopProcesses
$networkInfo = Get-NetworkInfo

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportName = "Audit-$($env:COMPUTERNAME)-$timestamp.html"

$report = @"
<h1>System Audit Report</h1>
<h2>OS Information</h2>
$($osInfo | ConvertTo-Html -Fragment)

<h2>Disk Information</h2>
$($diskInfo | ConvertTo-Html -Fragment)

<h2>Top 10 Processes</h2>
$($topProcesses | ConvertTo-Html -Fragment)

<h2>Network Information</h2>
$($networkInfo | ConvertTo-Html -Fragment)
"@

$report | Out-File $reportName
Write-Host "Report generated: $reportName"