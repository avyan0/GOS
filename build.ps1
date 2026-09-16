# Packages the game for release:
#   dist\GodsOfSpace.love            - runs anywhere LÖVE 11.x is installed
#   dist\GodsOfSpace-win64\           - self-contained Windows build (drop the folder in a zip)
# Usage: powershell -ExecutionPolicy Bypass -File build.ps1
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$love = 'C:\Program Files\LOVE'
$dist = Join-Path $root 'dist'
New-Item -ItemType Directory -Force $dist | Out-Null

# .love is just a zip of the game folder (only what the game needs)
$loveFile = Join-Path $dist 'GodsOfSpace.love'
$zip = Join-Path $dist 'GodsOfSpace.zip'
Remove-Item -Force -ErrorAction SilentlyContinue $loveFile, $zip
Compress-Archive -Path (Join-Path $root 'main.lua'), (Join-Path $root 'conf.lua'), (Join-Path $root 'src'), (Join-Path $root 'assets') -DestinationPath $zip
Move-Item $zip $loveFile
Write-Host "wrote $loveFile"

# Windows build: love.exe + game fused, plus the DLLs and license from the LÖVE install
$win = Join-Path $dist 'GodsOfSpace-win64'
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $win
New-Item -ItemType Directory -Force $win | Out-Null
$exe = Join-Path $win 'GodsOfSpace.exe'
cmd /c "copy /b `"$love\love.exe`"+`"$loveFile`" `"$exe`"" | Out-Null
Get-ChildItem $love -Filter '*.dll' | Copy-Item -Destination $win
Copy-Item (Join-Path $love 'license.txt') $win -ErrorAction SilentlyContinue
Write-Host "wrote $win"
