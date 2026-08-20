# Install a desktop shortcut for DSH WhaleGirl Launcher (portable).
$ErrorActionPreference = 'Stop'

$launcherDir = $PSScriptRoot
$ps1  = Join-Path $launcherDir 'launch-dsh.ps1'
$ico  = Join-Path $launcherDir 'whale-girl.ico'
if (-not (Test-Path $ps1)) { throw "Missing launch-dsh.ps1 in: $launcherDir" }
if (-not (Test-Path $ico)) { throw "Missing whale-girl.ico in: $launcherDir" }

$powershell = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$desktop  = [Environment]::GetFolderPath('Desktop')
$lnkName  = 'DSH ' + [char]0x9CB8 + [char]0x9C7C + [char]0x5A18 + '.lnk'
$lnkPath  = Join-Path $desktop $lnkName

$ws  = New-Object -ComObject WScript.Shell
$lnk = $ws.CreateShortcut($lnkPath)
$lnk.TargetPath       = $powershell
$lnk.Arguments        = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $ps1 + '"'
$lnk.IconLocation     = $ico + ',0'
$lnk.WorkingDirectory = $launcherDir
$lnk.Description      = 'DSH WhaleGirl Launcher (portable)'
$lnk.Save()

Write-Host "Installed: $lnkPath"
