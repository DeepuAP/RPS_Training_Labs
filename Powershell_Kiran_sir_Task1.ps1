$Path = Read-Host "Enter File Path"

if($Path){
    Get-ChildItem -Path $Path -Recurse -File |
    Select-Object Name,
                  Extension,
                  @{Name="SizeKB"; Expression={ $_.Length / 1KB }},
                  LastWriteTime,
                  @{Name="LargeFile"; Expression={ $_.Length -gt 5MB }} |
    Sort-Object SizeKB -Descending |
    Export-Csv "FileReport.csv" -NoTypeInformation
}
