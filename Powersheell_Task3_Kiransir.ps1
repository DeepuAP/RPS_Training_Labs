# Function to get failed logon events
function Get-FailedLogons {
    Get-WinEvent -FilterHashtable @{
        LogName   = 'Security'
        Id        = 4625
        StartTime = (Get-Date).AddHours(-24)
    }
}

# Function to extract Account and IP
function Get-LogonData {
    param($Events)

    foreach ($event in $Events) {
        [PSCustomObject]@{
            Account = $event.Properties[5].Value
            IP      = $event.Properties[18].Value
        }
    }
}

# Function to get Top 10 grouped results
function Get-TopResults {
    param(
        $Data,
        $PropertyName
    )

    $Data |
    Where-Object { $_.$PropertyName -and $_.$PropertyName -ne "-" } |
    Group-Object $PropertyName |
    Sort-Object Count -Descending |
    Select-Object -First 10
}

# MAIN EXECUTION

$events = Get-FailedLogons
$data   = Get-LogonData -Events $events

$topAccounts = Get-TopResults -Data $data -PropertyName "Account"
$topIPs      = Get-TopResults -Data $data -PropertyName "IP"

# Export clean reports
$topAccounts |
Select-Object Name, Count |
Export-Csv "TopFailedAccounts.csv" -NoTypeInformation

$topIPs |
Select-Object Name, Count |
Export-Csv "TopFailedIPs.csv" -NoTypeInformation

Write-Host "Function-based report generated successfully"
