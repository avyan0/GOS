# Uploads the builds from build.ps1 to itch.io with butler (https://itch.io/docs/butler/).
# One-time setup:  butler login        (opens a browser)
# Usage:           powershell -ExecutionPolicy Bypass -File publish.ps1 -Project yourname/gods-of-space [-Version 1.0.0]
param(
    [Parameter(Mandatory = $true)][string]$Project,
    [string]$Version = (Get-Date -Format 'yyyy.MM.dd')
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$dist = Join-Path $root 'dist'
if (-not (Get-Command butler -ErrorAction SilentlyContinue)) {
    throw "butler not found. Install it from https://itch.io/docs/butler/ and run 'butler login' first."
}
& powershell -ExecutionPolicy Bypass -File (Join-Path $root 'build.ps1')

butler push (Join-Path $dist 'GodsOfSpace-win64') "$Project:windows" --userversion $Version
butler push (Join-Path $dist 'GodsOfSpace.love') "$Project:love" --userversion $Version
if (Test-Path (Join-Path $dist 'web\index.html')) {
    butler push (Join-Path $dist 'web') "$Project:html5" --userversion $Version
    Write-Host "Remember to tick 'This file will be played in the browser' on the html5 channel and set the viewport to 1280x720."
}
Write-Host "published $Project version $Version"
