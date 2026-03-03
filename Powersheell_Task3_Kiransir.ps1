# Get failed logon events from last 24 hours
$events = Get-WinEvent -FilterHashtable @{
    LogName   = 'Security'
    Id        = 4625
    StartTime = (Get-Date).AddHours(-24)
}

# Extract Account and IP Address
$data = foreach ($event in $events) {
    [PSCustomObject]@{
        Account = $event.Properties[5].Value
        IP      = $event.Properties[18].Value
    }
}

# Top 10 Accounts
$topAccounts = $data |
Where-Object { $_.Account -and $_.Account -ne "-" } |
Group-Object Account |
Sort-Object Count -Descending |
Select-Object -First 10

# Top 10 IPs
$topIPs = $data |
Where-Object { $_.IP -and $_.IP -ne "-" } |
Group-Object IP |
Sort-Object Count -Descending |
Select-Object -First 10

# Export Clean Reports (Important Fix Here)
$topAccounts |
Select-Object Name, Count |
Export-Csv "TopFailedAccounts.csv" -NoTypeInformation

$topIPs |
Select-Object Name, Count |
Export-Csv "TopFailedIPs.csv" -NoTypeInformation

Write-Host "Report Generated Successfully"
