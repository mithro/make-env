param (
    [string]$filename
)

New-Item -Path $filename -ItemType directory -Force | Out-Null
