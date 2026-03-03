# Get failed logon events from last 24 hours
$events = Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    Id = 4625
    StartTime = (Get-Date).AddHours(-24)
}

# Extract account and IP
$data = foreach ($event in $events) {
    [PSCustomObject]@{
        Account = $event.Properties[5].Value
        IP      = $event.Properties[18].Value
    }
}

# Top 10 accounts
$topAccounts = $data |
Group-Object Account |
Sort-Object Count -Descending |
Select-Object -First 10

# Top 10 IPs
$topIPs = $data |
Group-Object IP |
Sort-Object Count -Descending |
Select-Object -First 10

# Export reports
$topAccounts | Export-Csv "TopFailedAccounts.csv" -NoTypeInformation
$topIPs | Export-Csv "TopFailedIPs.csv" -NoTypeInformation
