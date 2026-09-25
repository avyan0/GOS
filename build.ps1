# Packages the game for release:
#   dist\GodsOfSpace.love              - runs anywhere LÖVE 11.x is installed (Linux / macOS / Windows)
#   dist\GodsOfSpace-win64\            - self-contained Windows build
#   dist\GodsOfSpace-win64.zip         - the same, zipped for itch.io / uploads
#   dist\web\                          - browser build via love.js (optional, needs Node; -SkipWeb to skip)
# Usage: powershell -ExecutionPolicy Bypass -File build.ps1 [-SkipWeb]
param([switch]$SkipWeb)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$love = 'C:\Program Files\LOVE'
$dist = Join-Path $root 'dist'
New-Item -ItemType Directory -Force $dist | Out-Null

# .love is just a zip of the game folder (only what the game needs)
$loveFile = Join-Path $dist 'GodsOfSpace.love'
$zip = Join-Path $dist 'GodsOfSpace.zip'
Remove-Item -Force -ErrorAction SilentlyContinue $loveFile, $zip
Compress-Archive -Path (Join-Path $root 'main.lua'), (Join-Path $root 'conf.lua'), (Join-Path $root 'src'), (Join-Path $root 'assets'), (Join-Path $root 'CREDITS.txt') -DestinationPath $zip
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
Copy-Item (Join-Path $root 'CREDITS.txt'), (Join-Path $root 'assets/fonts/OFL.txt') $win
$winZip = Join-Path $dist 'GodsOfSpace-win64.zip'
Remove-Item -Force -ErrorAction SilentlyContinue $winZip
Compress-Archive -Path $win -DestinationPath $winZip
Write-Host "wrote $win and $winZip"

# Browser build (love.js, compatibility mode so it runs without special HTTP headers)
if (-not $SkipWeb) {
    if (Get-Command node -ErrorAction SilentlyContinue) {
        $web = Join-Path $dist 'web'
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $web
        # love.js is installed locally once (npx hangs launching it on Windows)
        $lovejs = Join-Path $root 'tools/web/node_modules/love.js/index.js'
        if (-not (Test-Path $lovejs)) { & npm install --silent --prefix (Join-Path $root 'tools/web') love.js@11.4.1 | Out-Null }
        & node $lovejs -c -m 134217728 -t "Gods of Space" $loveFile $web
        if (Test-Path (Join-Path $web 'index.html')) {
            $webZip = Join-Path $dist 'GodsOfSpace-web.zip'
            Remove-Item -Force -ErrorAction SilentlyContinue $webZip
            Compress-Archive -Path (Join-Path $web '*') -DestinationPath $webZip
            Write-Host "wrote $web and $webZip "
        } else { Write-Host "web build skipped: love.js did not produce output" }
    } else { Write-Host "web build skipped: node not found" }
}
