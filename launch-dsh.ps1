# DSH WhaleGirl Launcher (portable)
# Cleans leftover dsh* plugin folders that break DSH startup, boots DSH Web,
# then opens the browser. Works with or without plugins installed.
$ErrorActionPreference = 'SilentlyContinue'

# ---------------- configuration ----------------
$CleanBrokenPlugins = $true        # remove dsh* leftover plugin folders before cold boot
$DshUrl             = 'http://127.0.0.1:3080'
$OpenBrowser        = $true
# -----------------------------------------------

$launcherDir = $PSScriptRoot
if ($env:DSH_HOME) { $dshHome = $env:DSH_HOME } else { $dshHome = Join-Path $env:USERPROFILE '.dsh' }
$logFile = Join-Path $dshHome 'launcher.log'
$port    = ([Uri]$DshUrl).Port

function Write-Log([string]$msg) {
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $msg"
    try { $line | Out-File -FilePath $logFile -Append -Encoding utf8 } catch { }
}

function Test-DshRunning {
    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $iar = $client.BeginConnect('127.0.0.1', $port, $null, $null)
        $ok = $iar.AsyncWaitHandle.WaitOne(700)
        $client.Close()
        if ($ok) { return $true }
    } catch { }
    if (Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue) { return $true }
    return $false
}

function Find-Node {
    $g = (Get-Command node -ErrorAction SilentlyContinue | Select-Object -First 1).Source
    if ($g -and (Test-Path $g)) { return $g }
    foreach ($p in @('C:\Program Files\nodejs\node.exe', 'C:\Program Files (x86)\nodejs\node.exe', (Join-Path $env:APPDATA 'npm\node.exe'))) {
        if ($p -and (Test-Path $p)) { return $p }
    }
    return $null
}

function Find-DshBin {
    $c = @()
    if ($env:APPDATA) { $c += Join-Path $env:APPDATA 'npm\node_modules\@deepseek-ai\dsh\lib\bin.js' }
    $shim = (Get-Command dsh.cmd -ErrorAction SilentlyContinue | Select-Object -First 1).Source
    if ($shim) { $c += Join-Path (Split-Path $shim -Parent) 'node_modules\@deepseek-ai\dsh\lib\bin.js' }
    foreach ($p in $c) { if (Test-Path $p) { return $p } }
    return $null
}

function Show-Message([string]$text, [string]$title) {
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        [System.Windows.Forms.MessageBox]::Show($text, $title, 0, 64) | Out-Null
    } catch {
        try {
            $f = Join-Path $env:TEMP ('dsh-launcher-' + [Guid]::NewGuid().ToString('N') + '.txt')
            Set-Content -LiteralPath $f -Value $text -Encoding utf8
            Start-Process 'notepad.exe' -ArgumentList $f
        } catch { }
    }
}

Write-Log "launcher invoked (home=$dshHome)"

if (Test-DshRunning) {
    Write-Log "DSH already running on $DshUrl"
    if ($OpenBrowser) { Start-Process $DshUrl }
    exit 0
}

# 1) clean broken dsh* plugin folders
if ($CleanBrokenPlugins) {
    $pkgDir = Join-Path $dshHome 'profiles\web\node_modules\@deepseek-ai'
    if (Test-Path $pkgDir) {
        $found = Get-ChildItem -Path $pkgDir -Directory -Filter 'dsh*' -ErrorAction SilentlyContinue
        foreach ($f in $found) {
            Remove-Item -LiteralPath $f.FullName -Recurse -Force
            if (-not (Test-Path -LiteralPath $f.FullName)) { Write-Log "removed plugin folder: $($f.Name)" }
            else { Write-Log "FAILED to remove plugin folder: $($f.Name)" }
        }
        if (-not $found) { Write-Log "no dsh* plugin folders to clean" }
    } else {
        Write-Log "plugin dir not present (first run or no plugins)"
    }
}

# 2) boot DSH
$node = Find-Node
$bin  = Find-DshBin
if ($node -and $bin) {
    Write-Log "starting: $node $bin web"
    Start-Process -FilePath $node -ArgumentList @($bin, 'web') -WorkingDirectory $env:USERPROFILE
} else {
    $shim = if ($env:APPDATA) { Join-Path $env:APPDATA 'npm\dsh.cmd' } else { $null }
    if ($shim -and (Test-Path $shim)) {
        Write-Log "starting via shim: $shim web"
        Start-Process -FilePath $shim -ArgumentList 'web' -WorkingDirectory $env:USERPROFILE
    } else {
        Write-Log "DSH not found (node=$node bin=$bin shim=$shim)"
        Show-Message '未找到 DSH。请先安装 Node.js，再执行: npm install -g @deepseek-ai/dsh' 'DSH WhaleGirl Launcher'
        exit 1
    }
}

# 3) wait for the server, then open the browser
$started = $false
for ($i = 0; $i -lt 20; $i++) {
    Start-Sleep -Seconds 1
    if (Test-DshRunning) { $started = $true; break }
}
if ($started) { Write-Log "DSH is up after $($i + 1)s" } else { Write-Log "DSH did not come up within 20s (see DSH console)" }
if ($OpenBrowser) { Start-Process $DshUrl }
