# =============================================================
#  Windows 智能清理脚本 (PowerShell)
#  用法 (在 PowerShell 中运行):
#     .\smart-clean.ps1 -List     仅扫描并列出可清理项，不删除
#     .\smart-clean.ps1 -Clean    进入交互确认模式（默认）
#     .\smart-clean.ps1 -Yes      直接清理所有[安全]项，[需判断]项仍提问
#     .\smart-clean.ps1 -Help     查看帮助
#
#  若执行策略阻止运行:  powershell -ExecutionPolicy Bypass -File .\smart-clean.ps1
# =============================================================

param(
    [switch]$List,
    [switch]$Clean,
    [switch]$Yes,
    [switch]$Help
)

# ---------- 帮助 ----------
if ($Help) {
    @"
Windows 智能清理脚本
用法:
  .\smart-clean.ps1 -List   仅列出可清理项(推荐先看)
  .\smart-clean.ps1 -Clean  交互确认后清理(默认)
  .\smart-clean.ps1 -Yes    自动清理[安全]项，[需判断]项仍提问
说明:
  [安全]   可再生缓存/临时文件，删除无风险
  [需判断] 可能含用户数据或正在使用，需逐项确认
"@
    exit 0
}

# ---------- 默认进入交互模式 ----------
if (-not $List -and -not $Clean -and -not $Yes) { $Clean = $true }

# ---------- 阈值 ----------
$MIN_SIZE  = 10MB      # 低于该值不列出
$WARN_SIZE = 200MB     # 大文件标记阈值

# ---------- 结果容器 ----------
$Safe = @()            # [安全]
$Rev  = @()            # [需判断]
$TotalSafe = 0
$TotalRev  = 0

# =============================================================
# 辅助函数
# =============================================================
function Get-Size-Human {
    param([long]$Bytes)
    if ($Bytes -ge 1GB) { return '{0:N1}G' -f ($Bytes / 1GB) }
    if ($Bytes -ge 1MB) { return '{0:N1}M' -f ($Bytes / 1MB) }
    if ($Bytes -ge 1KB) { return '{0:N0}K' -f ($Bytes / 1KB) }
    return "$Bytes B"
}

function Get-Path-Size {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return 0 }
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if (-not $item) { return 0 }
    if (-not $item.PSIsContainer) { return $item.Length }

    # 目录递归求和（忽略无权限/锁定的文件）
    $sum = 0L
    try {
        $files = Get-ChildItem -LiteralPath $Path -Recurse -File -Force -ErrorAction SilentlyContinue
        foreach ($f in $files) { $sum += $f.Length }
    } catch {}
    return $sum
}

function Get-RecycleBin-Size {
    try {
        $shell = New-Object -ComObject Shell.Application
        $items = $shell.NameSpace(10).Items()
        $sum = 0L
        foreach ($it in $items) { $sum += [long]$it.Size }
        return $sum
    } catch { return 0 }
}

function Add-Item {
    param([string]$Category, [string]$Path, [string]$Desc, [string]$Command, [long]$ForceSize = -1)
    if ($ForceSize -ge 0) { $size = $ForceSize } else { $size = Get-Path-Size -Path $Path }
    if ($size -lt $MIN_SIZE) { return }   # 太小不列出

    $entry = [PSCustomObject]@{
        Path    = $Path
        Desc    = $Desc
        Bytes   = $size
        Command = $Command
    }
    if ($Category -eq 'safe') {
        $script:Safe += $entry
        $script:TotalSafe += $size
    } else {
        $script:Rev += $entry
        $script:TotalRev += $size
    }
}

function Invoke-Cleanup {
    param([object]$Entry)
    Write-Host "执行: $($Entry.Command)" -ForegroundColor DarkGray
    try {
        # 对 rm -rf 形式的命令做安全转换
        if ($Entry.Command -match '^Remove-Item') {
            Invoke-Expression $Entry.Command -ErrorAction SilentlyContinue
        } elseif ($Entry.Command -match '^Empty-') {
            # 清空目录内容
            Get-ChildItem -LiteralPath $Entry.Path -Force -ErrorAction SilentlyContinue |
                Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        } else {
            Invoke-Expression $Entry.Command -ErrorAction SilentlyContinue
        }
    } catch {}

    Start-Sleep -Milliseconds 500
    # 校验
    $remaining = Get-Path-Size -Path $Entry.Path
    if ($remaining -gt 0) {
        Write-Host "  [警告] 可能仍有残留: $($Entry.Path) ($(Get-Size-Human $remaining))" -ForegroundColor Yellow
    } else {
        Write-Host "  [完成] 已清理" -ForegroundColor Green
    }
}

# =============================================================
# 扫描 [安全] 项 (可再生缓存/临时文件)
# =============================================================

# 用户临时文件 %TEMP% / %TMP%
Add-Item -Category safe -Path $env:TEMP -Desc "用户临时文件(TEMP)" `
    -Command 'Get-ChildItem -LiteralPath $env:TEMP -Force -EA SilentlyContinue | Remove-Item -Recurse -Force -EA SilentlyContinue'

# 系统临时目录 C:\Windows\Temp (需管理员)
if (Test-Path 'C:\Windows\Temp') {
    Add-Item -Category safe -Path 'C:\Windows\Temp' -Desc "系统临时文件(Win\Temp)" `
        -Command 'Get-ChildItem -LiteralPath C:\Windows\Temp -Force -EA SilentlyContinue | Remove-Item -Recurse -Force -EA SilentlyContinue'
}

# Windows 更新缓存
Add-Item -Category safe -Path 'C:\Windows\SoftwareDistribution\Download' -Desc "Windows 更新缓存" `
    -Command 'Get-ChildItem -LiteralPath C:\Windows\SoftwareDistribution\Download -Force -EA SilentlyContinue | Remove-Item -Recurse -Force -EA SilentlyContinue'

# 缩略图缓存
Add-Item -Category safe -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer" -Desc "缩略图缓存(Explorer)" `
    -Command 'Get-ChildItem -LiteralPath $env:LOCALAPPDATA\Microsoft\Windows\Explorer -Filter thumbcache_*.db -Force -EA SilentlyContinue | Remove-Item -Force -EA SilentlyContinue'

# npm 缓存
Add-Item -Category safe -Path "$env:LOCALAPPDATA\npm-cache" -Desc "npm 缓存" `
    -Command 'npm cache clean --force 2>$null; Remove-Item -LiteralPath $env:LOCALAPPDATA\npm-cache -Recurse -Force -EA SilentlyContinue'

# pip 缓存
Add-Item -Category safe -Path "$env:LOCALAPPDATA\pip\cache" -Desc "pip 缓存" `
    -Command 'pip cache purge 2>$null; Remove-Item -LiteralPath $env:LOCALAPPDATA\pip\cache -Recurse -Force -EA SilentlyContinue'

# NuGet 缓存
Add-Item -Category safe -Path "$env:USERPROFILE\.nuget\packages" -Desc "NuGet 缓存" `
    -Command 'Remove-Item -LiteralPath $env:USERPROFILE\.nuget\packages -Recurse -Force -EA SilentlyContinue'

# Windows 错误报告
Add-Item -Category safe -Path "$env:LOCALAPPDATA\Microsoft\Windows\WER" -Desc "Windows 错误报告(WER)" `
    -Command 'Get-ChildItem -LiteralPath $env:LOCALAPPDATA\Microsoft\Windows\WER -Recurse -Force -EA SilentlyContinue | Remove-Item -Recurse -Force -EA SilentlyContinue'

# Crash 转储 (.dmp / .hprof)
$dmpFiles = Get-ChildItem "$env:USERPROFILE" -Filter '*.dmp' -File -Recurse -Depth 2 -Force -EA SilentlyContinue
foreach ($d in $dmpFiles) {
    Add-Item -Category safe -Path $d.FullName -Desc "崩溃转储: $($d.Name)" `
        -Command "Remove-Item -LiteralPath '$($d.FullName)' -Force -EA SilentlyContinue"
}
$hprofFiles = Get-ChildItem "$env:USERPROFILE" -Filter '*.hprof' -File -Recurse -Depth 2 -Force -EA SilentlyContinue
foreach ($h in $hprofFiles) {
    Add-Item -Category safe -Path $h.FullName -Desc "JVM崩溃转储: $($h.Name)" `
        -Command "Remove-Item -LiteralPath '$($h.FullName)' -Force -EA SilentlyContinue"
}

# 回收站 (Empty Recycle Bin)
$recycleSize = Get-RecycleBin-Size
if ($recycleSize -ge $MIN_SIZE) {
    Add-Item -Category safe -Path 'C:\$Recycle.Bin' -Desc "回收站(Recycle Bin)" `
        -Command 'Clear-RecycleBin -Force -EA SilentlyContinue' -ForceSize $recycleSize
}

# =============================================================
# 扫描 [需判断] 项
# =============================================================

# HuggingFace 模型缓存
Add-Item -Category rev -Path "$env:USERPROFILE\.cache\huggingface" -Desc "HuggingFace 模型缓存(本地推理才用)" `
    -Command 'Remove-Item -LiteralPath $env:USERPROFILE\.cache\huggingface -Recurse -Force -EA SilentlyContinue'

# Codex 运行时
Add-Item -Category rev -Path "$env:USERPROFILE\.codex" -Desc "Codex 配置/缓存(未用可删)" `
    -Command 'Remove-Item -LiteralPath $env:USERPROFILE\.codex -Recurse -Force -EA SilentlyContinue'

# 全局 npm 大包 (>200MB)
$npmGlobal = "$env:APPDATA\npm\node_modules"
if (Test-Path $npmGlobal) {
    Get-ChildItem $npmGlobal -Directory -Force -EA SilentlyContinue | ForEach-Object {
        $s = Get-Path-Size $_.FullName
        if ($s -ge $WARN_SIZE) {
            Add-Item -Category rev -Path $_.FullName -Desc "全局 npm 包: $($_.Name)" `
                -Command "npm uninstall -g --silent `"$($_.Name)`" 2>`$null; Remove-Item -LiteralPath '$($_.FullName)' -Recurse -Force -EA SilentlyContinue"
        }
    }
}

# 项目级 node_modules (>500MB)
Get-ChildItem $env:USERPROFILE -Directory -Filter node_modules -Recurse -Depth 3 -Force -EA SilentlyContinue |
    Where-Object { (Get-Path-Size $_.FullName) -ge 500MB } | ForEach-Object {
        Add-Item -Category rev -Path $_.FullName -Desc "项目依赖: $($_.FullName.Replace($env:USERPROFILE+'\','')) (删除需重装)" `
            -Command "Remove-Item -LiteralPath '$($_.FullName)' -Recurse -Force -EA SilentlyContinue"
    }

# Downloads 大文件 (>200MB)
Get-ChildItem "$env:USERPROFILE\Downloads" -File -Force -EA SilentlyContinue |
    Where-Object { $_.Length -ge $WARN_SIZE } | ForEach-Object {
        Add-Item -Category rev -Path $_.FullName -Desc "下载文件夹大文件: $($_.Name)" `
            -Command "Remove-Item -LiteralPath '$($_.FullName)' -Force -EA SilentlyContinue"
    }

# 用户目录 >1GB 大文件
Get-ChildItem $env:USERPROFILE -File -Recurse -Depth 3 -Force -EA SilentlyContinue |
    Where-Object {
        $_.Length -ge 1GB -and
        $_.FullName -notmatch '\\(AppData|node_modules|\.git|\.cache)\\' -and
        $_.Extension -notin '.dmp','.hprof'
    } | ForEach-Object {
        Add-Item -Category rev -Path $_.FullName -Desc "大文件(>1GB): $($_.FullName.Replace($env:USERPROFILE+'\',''))" `
            -Command "Remove-Item -LiteralPath '$($_.FullName)' -Force -EA SilentlyContinue"
    }

# =============================================================
# 打印清单
# =============================================================
function Write-List {
    Write-Host ""
    Write-Host "========== 扫描结果 ==========" -ForegroundColor Cyan

    Write-Host ""
    Write-Host "[安全] 可直接删除 (可再生缓存/临时文件)  共 $(Get-Size-Human $TotalSafe)" -ForegroundColor Green
    if ($Safe.Count -eq 0) {
        Write-Host "  (无)"
    } else {
        $i = 1
        foreach ($e in $Safe) {
            Write-Host ("  {0}. {1}  {2}  [{3}]" -f $i, $e.Desc, $e.Path, (Get-Size-Human $e.Bytes)) -ForegroundColor Green
            $i++
        }
    }

    Write-Host ""
    Write-Host "[需判断] 请确认是否删除 (可能含数据或在使用)  共 $(Get-Size-Human $TotalRev)" -ForegroundColor Yellow
    if ($Rev.Count -eq 0) {
        Write-Host "  (无)"
    } else {
        foreach ($e in $Rev) {
            Write-Host ("  - {0}  {1}  [{2}]" -f $e.Desc, $e.Path, (Get-Size-Human $e.Bytes)) -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host "命令行: -List(仅列出)  -Clean(交互确认)  -Yes(自动删安全项, 需判断项仍提问)"
}

# =============================================================
# 交互确认 & 清理
# =============================================================
function Do-Clean {
    Write-Host ""
    Write-Host "── 第 1 步: 处理 [安全] 项 ──" -ForegroundColor Cyan
    if ($Safe.Count -eq 0) {
        Write-Host "  (无安全项可清理)"
    } else {
        foreach ($e in $Safe) {
            if ($Yes) {
                Write-Host "[--yes 自动确认] $($e.Desc)" -ForegroundColor DarkGray
                Invoke-Cleanup $e
                continue
            }
            $ans = Read-Host "删除 [安全] $($e.Desc) [$($e.Path)] ($(Get-Size-Human $e.Bytes))? [y/N]"
            if ($ans -match '^y') { Invoke-Cleanup $e } else { Write-Host "  跳过" }
        }
    }

    Write-Host ""
    Write-Host "── 第 2 步: 处理 [需判断] 项 ──" -ForegroundColor Cyan
    if ($Rev.Count -eq 0) {
        Write-Host "  (无)"
    } else {
        foreach ($e in $Rev) {
            $ans = Read-Host "[需判断] $($e.Desc) [$($e.Path)] ($(Get-Size-Human $e.Bytes)) 确认删除? [y/N]"
            if ($ans -match '^y') { Invoke-Cleanup $e } else { Write-Host "  跳过" }
        }
    }
    Write-Host ""
    Write-Host "清理结束" -ForegroundColor Green
}

# =============================================================
# 主流程
# =============================================================
if ($List) {
    Write-List
} else {
    Write-List
    $confirm = Read-Host "是否开始清理? [y/N]"
    if ($confirm -match '^y') { Do-Clean } else { Write-Host "已取消，未删除任何内容。" }
}