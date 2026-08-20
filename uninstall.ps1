$ErrorActionPreference = 'SilentlyContinue'
$desktop = [Environment]::GetFolderPath('Desktop')
$lnkName = 'DSH ' + [char]0x9CB8 + [char]0x9C7C + [char]0x5A18 + '.lnk'
$lnkPath = Join-Path $desktop $lnkName
if (Test-Path $lnkPath) { Remove-Item -LiteralPath $lnkPath -Force; Write-Host "Removed: $lnkPath" } else { Write-Host "No shortcut found." }
