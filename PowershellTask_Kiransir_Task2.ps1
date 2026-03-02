param(
    [switch]$Fix
)

# Get services that are Stopped but set to Automatic
$services = Get-Service | Where-Object {
    $_.Status -eq 'Stopped' -and $_.StartType -eq 'Automatic'
}

# Display on screen
$services | Format-Table Name, Status, StartType

# Create timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# Export report
$services | Export-Csv "ServiceReport_$timestamp.csv" -NoTypeInformation

# If -Fix switch is used, start those services
if($Fix){
    foreach($svc in $services){
        Start-Service -Name $svc.Name
    }
}
