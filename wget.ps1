$url=$args[0]
$o=$args[1]
$output=$args[2]

# Download with HTTPS
$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
$ProgressPreference = 'SilentlyContinue' # Faster download with Invoke-WebRequest

$outdir = Split-Path -Path $output
New-Item -Path $outdir -ItemType directory -Force

If(!(test-path $output)) {
    Write-Host "'$output' is missing."
    Invoke-WebRequest $url -OutFile $output
    Write-Host "'$output' download."
} else {
    Write-Host "'$output' already exists."
}
