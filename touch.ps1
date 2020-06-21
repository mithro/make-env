param (
    [string]$filename
)

if (Test-Path $filename) {
    (Get-ChildItem $filename).LastWriteTime = Get-Date
} else {
    New-Item -Path $filename -ItemType File | Out-Null
}
