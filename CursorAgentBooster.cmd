@echo off
setlocal EnableExtensions
cd /d "%~dp0"
chcp 65001 >nul
title Cursor Rules Installer
color 0B

where powershell >nul 2>&1
if errorlevel 1 (
    color 0C
    echo.
    echo  [ERROR] PowerShell not found.
    echo.
    pause
    exit /b 1
)

set "HOSTFILE=%~f0"
set "DRYRUN="
set "ROLLBACK="
if /i "%~1"=="test" set "DRYRUN=1"
if /i "%~1"=="rollback" set "ROLLBACK=1"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$h=$env:HOSTFILE; $d=$env:DRYRUN; $r=$env:ROLLBACK; $t=[IO.File]::ReadAllText($h); $m='::PS1::'; $i=$t.LastIndexOf($m); if($i -lt 0){Write-Host 'ERROR: script marker missing' -ForegroundColor Red; exit 1}; $p=Join-Path $env:TEMP ('cursor-rules-' + [guid]::NewGuid().ToString() + '.ps1'); [IO.File]::WriteAllText($p, $t.Substring($i + $m.Length).TrimStart([char]13,[char]10), [Text.UTF8Encoding]::new($true)); $psParams=@{}; if($d -eq '1'){$psParams.DryRun=$true}; if($r -eq '1'){$psParams.Rollback=$true}; try { & $p @psParams } finally { Remove-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue }; exit $LASTEXITCODE"

set "RC=%ERRORLEVEL%"
exit /b %RC%

::PS1::
param(
    [switch]$DryRun,
    [switch]$Rollback
)

$ErrorActionPreference = "Stop"
$Script:Lang = "ru"
$script:Mode = "install"
$script:IsDryRun = $false
$script:AutoConfirm = $DryRun.IsPresent -or $Rollback.IsPresent

$Script:I18n = @{
    "title.install"    = @{ ru = "УСТАНОВКА ПРАВИЛ CURSOR"; en = "CURSOR USER RULES INSTALLER" }
    "title.test"       = @{ ru = "ТЕСТОВЫЙ РЕЖИМ (БЕЗ ИЗМЕНЕНИЙ)"; en = "TEST MODE (NO CHANGES)" }
    "title.rollback"   = @{ ru = "ОТКАТ ИЗМЕНЕНИЙ"; en = "ROLLBACK CHANGES" }
    "subtitle"         = @{ ru = "8 user rules  ->  %USERPROFILE%\.cursor\rules\"; en = "8 user rules  ->  %USERPROFILE%\.cursor\rules\" }
    "lang.prompt"      = @{ ru = "Выберите язык / Select language:"; en = "Select language / Выберите язык:" }
    "lang.ru"          = @{ ru = "[1] Русский"; en = "[1] Russian" }
    "lang.en"          = @{ ru = "[2] English"; en = "[2] English" }
    "lang.choice"      = @{ ru = "Ваш выбор (1/2)"; en = "Your choice (1/2)" }
    "lang.invalid"     = @{ ru = "Неверный ввод. Повторите."; en = "Invalid input. Try again." }
    "mode.prompt"      = @{ ru = "Выберите режим / Select mode:"; en = "Select mode / Выберите режим:" }
    "mode.install"     = @{ ru = "[1] Установить правила"; en = "[1] Install rules" }
    "mode.test"        = @{ ru = "[2] Тест (без изменений)"; en = "[2] Test (no changes)" }
    "mode.rollback"    = @{ ru = "[3] Откатить все изменения"; en = "[3] Rollback all changes" }
    "mode.choice"      = @{ ru = "Ваш выбор (1/2/3)"; en = "Your choice (1/2/3)" }
    "mode.testinfo"    = @{ ru = "РЕЖИМ: только просмотр — файлы НЕ изменяются"; en = "MODE: preview only — files will NOT be changed" }
    "mode.installinfo" = @{ ru = "РЕЖИМ: установка правил"; en = "MODE: install rules" }
    "mode.rollbackinfo"= @{ ru = "РЕЖИМ: восстановление из резервной копии"; en = "MODE: restore from backup" }
    "backup.note"      = @{ ru = "Перед изменениями создаётся резервная копия. При проблемах все изменения надёжно откатываются через [3] Откатить."; en = "A backup is created before changes. If anything goes wrong, all changes can be safely rolled back via [3] Rollback." }
    "section.target"   = @{ ru = "Папка назначения"; en = "Target folder" }
    "section.backup"   = @{ ru = "Резервная копия"; en = "Backup" }
    "section.existing" = @{ ru = "Существующие правила"; en = "Existing rules" }
    "section.plan"     = @{ ru = "Правила для установки"; en = "Rules to install" }
    "section.summary"  = @{ ru = "Итог"; en = "Summary" }
    "existing.none"    = @{ ru = "  (папка пуста или не существует)"; en = "  (folder empty or missing)" }
    "existing.count"   = @{ ru = "Найдено файлов: {0}"; en = "Files found: {0}" }
    "ask.remove"       = @{ ru = "Удалить ВСЕ существующие правила (.mdc) перед установкой?"; en = "Delete ALL existing rules (.mdc) before install?" }
    "hint.remove"      = @{ ru = "[Y] Да  [N] Нет  [Enter] = Да"; en = "[Y] Yes  [N] No  [Enter] = Yes" }
    "ask.confirm"      = @{ ru = "Начать установку?"; en = "Start installation?" }
    "hint.confirm"     = @{ ru = "[Y] Да  [N] Отмена  [Enter] = Да"; en = "[Y] Yes  [N] Cancel  [Enter] = Yes" }
    "ask.rollback"     = @{ ru = "Восстановить правила из последней резервной копии?"; en = "Restore rules from the latest backup?" }
    "hint.rollback"    = @{ ru = "[Y] Да  [N] Отмена  [Enter] = Да"; en = "[Y] Yes  [N] Cancel  [Enter] = Yes" }
    "install.autofresh"= @{ ru = "Правила не найдены — установка начнётся автоматически."; en = "No rules found — installation will start automatically." }
    "cancelled"        = @{ ru = "Отменено пользователем."; en = "Cancelled by user." }
    "dry.prefix"       = @{ ru = "[ТЕСТ]"; en = "[TEST]" }
    "test.autocont"    = @{ ru = "продолжение без подтверждения"; en = "continuing without confirmation" }
    "act.mkdir"        = @{ ru = "Создать папку"; en = "Create folder" }
    "act.delete"       = @{ ru = "Удалить"; en = "Delete" }
    "act.create"       = @{ ru = "Создать"; en = "Create" }
    "act.update"       = @{ ru = "Обновить"; en = "Update" }
    "act.backup"       = @{ ru = "Сохранить в бекап"; en = "Save to backup" }
    "act.restore"      = @{ ru = "Восстановить"; en = "Restore" }
    "sum.created"      = @{ ru = "Создано"; en = "Created" }
    "sum.updated"      = @{ ru = "Обновлено"; en = "Updated" }
    "sum.skipped"      = @{ ru = "Пропущено"; en = "Skipped" }
    "sum.deleted"      = @{ ru = "Удалено"; en = "Deleted" }
    "sum.restored"     = @{ ru = "Восстановлено"; en = "Restored" }
    "sum.backup"       = @{ ru = "Файлов в бекапе"; en = "Files in backup" }
    "sum.total"        = @{ ru = "Всего правил в наборе"; en = "Rules in bundle" }
    "done.test"        = @{ ru = "Тест завершён. Запустите снова и выберите [1] Установить."; en = "Test complete. Run again and choose [1] Install." }
    "done.install"     = @{ ru = "Готово! Перезапустите Cursor. Откат: запустите снова -> [3] Откатить."; en = "Done! Restart Cursor. Rollback: run again -> [3] Rollback." }
    "done.rollback"    = @{ ru = "Откат выполнен. Состояние правил восстановлено из бекапа."; en = "Rollback complete. Rules restored from backup." }
    "backup.none"      = @{ ru = "Резервная копия не найдена. Сначала выполните установку."; en = "No backup found. Run install first." }
    "backup.path"      = @{ ru = "Путь бекапа"; en = "Backup path" }
    "press.enter"      = @{ ru = "Нажмите Enter для выхода..."; en = "Press Enter to exit..." }
    "rule.identity"    = @{ ru = "IDENTITY & CONFLICT OVERRIDE"; en = "IDENTITY & CONFLICT OVERRIDE" }
    "rule.cognition"   = @{ ru = "COGNITION & ROUTING"; en = "COGNITION & ROUTING" }
    "rule.exec"        = @{ ru = "EXECUTION & HANG PREVENTION"; en = "EXECUTION & HANG PREVENTION" }
    "rule.remote"      = @{ ru = "REMOTE OPS"; en = "REMOTE OPS" }
    "rule.fix"         = @{ ru = "FIX, CODE & DOCS"; en = "FIX, CODE & DOCS" }
    "rule.plan"        = @{ ru = "PLAN & B-TREE NAV"; en = "PLAN & B-TREE NAV" }
    "rule.compression" = @{ ru = "COMPRESSION & HOOKS"; en = "COMPRESSION & HOOKS" }
    "rule.logs"        = @{ ru = "LOGS & CHAT DIET"; en = "LOGS & CHAT DIET" }
}

function L([string]$Key) {
    $bucket = $Script:I18n[$Key]
    if (-not $bucket) { return $Key }
    $val = $bucket[$Script:Lang]
    if (-not $val) { $val = $bucket["ru"] }
    return [string]$val
}

function Write-Color([string]$Text, [string]$Color = "Gray") { Write-Host $Text -ForegroundColor $Color }
function Write-RuleLine([string]$Icon, [string]$Text, [string]$Color) { Write-Host ("  {0,-3} {1}" -f $Icon, $Text) -ForegroundColor $Color }

function Get-RulesDir { Join-Path $env:USERPROFILE ".cursor\rules" }
function Get-BackupRoot { Join-Path $env:USERPROFILE ".cursor\rules-installer-backup" }

function Get-LatestBackupDir {
    $root = Get-BackupRoot
    $latestFile = Join-Path $root "latest.txt"
    if (-not (Test-Path $latestFile)) { return $null }
    $stamp = (Get-Content -LiteralPath $latestFile -Raw).Trim()
    if ([string]::IsNullOrWhiteSpace($stamp)) { return $null }
    $dir = Join-Path $root $stamp
    if (-not (Test-Path $dir)) { return $null }
    return $dir
}

function New-RulesBackup([string]$RulesDir, [string]$Prefix) {
    $root = Get-BackupRoot
    New-Item -ItemType Directory -Path $root -Force | Out-Null
    $stamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
    $dest = Join-Path $root ($stamp + $Prefix)
    New-Item -ItemType Directory -Path $dest -Force | Out-Null

    $files = @()
    if (Test-Path $RulesDir) {
        $files = @(Get-ChildItem -LiteralPath $RulesDir -Filter "*.mdc" -File -ErrorAction SilentlyContinue)
        foreach ($f in $files) {
            Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $dest $f.Name) -Force
        }
    }

    $meta = [ordered]@{
        createdAt = (Get-Date).ToString("o")
        sourceDir = $RulesDir
        fileCount = $files.Count
        files     = @($files | ForEach-Object { $_.Name })
    }
    Set-Content -LiteralPath (Join-Path $dest "backup.json") -Value ($meta | ConvertTo-Json -Depth 4) -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $root "latest.txt") -Value ($stamp + $Prefix) -Encoding UTF8
    return $dest
}

function Show-Banner {
    Clear-Host
    $border = switch ($script:Mode) {
        "test" { "Yellow" }
        "rollback" { "Magenta" }
        default { "Cyan" }
    }
    $title = switch ($script:Mode) {
        "test" { L "title.test" }
        "rollback" { L "title.rollback" }
        default { L "title.install" }
    }
    $sub = (L "subtitle").Replace("%USERPROFILE%", $env:USERPROFILE)
    Write-Host ""
    Write-Host "  +------------------------------------------------------------------+" -ForegroundColor $border
    Write-Host ("  |  {0,-62}|" -f $title.Substring(0, [Math]::Min(62, $title.Length))) -ForegroundColor $border
    Write-Host ("  |  {0,-62}|" -f $sub.Substring(0, [Math]::Min(62, $sub.Length))) -ForegroundColor DarkGray
    Write-Host "  +------------------------------------------------------------------+" -ForegroundColor $border
    Write-Host ""
    $info = switch ($script:Mode) {
        "test" { L "mode.testinfo" }
        "rollback" { L "mode.rollbackinfo" }
        default { L "mode.installinfo" }
    }
    Write-Color ("  >> " + $info) $border
    if ($script:Mode -eq "install") {
        Write-Color ("  >> " + (L "backup.note")) "DarkCyan"
    }
    Write-Host ""
}

function Select-Language {
    if ($script:AutoConfirm) {
        if ($env:CURSOR_RULES_LANG -eq "en") { $Script:Lang = "en" } else { $Script:Lang = "ru" }
        return
    }
    while ($true) {
        Write-Host ""
        Write-Color ("  " + (L "lang.prompt")) "White"
        Write-Color ("  " + (L "lang.ru")) "DarkCyan"
        Write-Color ("  " + (L "lang.en")) "DarkCyan"
        Write-Host ""
        $raw = Read-Host ("  " + (L "lang.choice"))
        $choice = if ($null -eq $raw) { "" } else { $raw.Trim() }
        switch ($choice) {
            "1" { $Script:Lang = "ru"; return }
            "2" { $Script:Lang = "en"; return }
            ""  { $Script:Lang = "ru"; return }
            default { Write-Color ("  " + (L "lang.invalid")) "Red" }
        }
    }
}

function Select-Mode {
    if ($DryRun.IsPresent) { $script:Mode = "test"; $script:IsDryRun = $true; return }
    if ($Rollback.IsPresent) { $script:Mode = "rollback"; return }
    while ($true) {
        Write-Host ""
        Write-Color ("  " + (L "mode.prompt")) "White"
        Write-Color ("  " + (L "mode.install")) "Green"
        Write-Color ("  " + (L "mode.test")) "Yellow"
        Write-Color ("  " + (L "mode.rollback")) "Magenta"
        Write-Host ""
        $raw = Read-Host ("  " + (L "mode.choice"))
        $choice = if ($null -eq $raw) { "" } else { $raw.Trim() }
        switch ($choice) {
            "1" { $script:Mode = "install"; $script:IsDryRun = $false; return }
            "2" { $script:Mode = "test"; $script:IsDryRun = $true; return }
            "3" { $script:Mode = "rollback"; return }
            ""  { $script:Mode = "install"; $script:IsDryRun = $false; return }
            default { Write-Color ("  " + (L "lang.invalid")) "Red" }
        }
    }
}

function Read-YesNo([string]$Prompt, [string]$Hint, [bool]$DefaultYes) {
    Write-Host ""
    Write-Color ("  ? " + $Prompt) "White"
    Write-Color ("    " + $Hint) "DarkGray"
    if ($script:AutoConfirm -or $script:IsDryRun) {
        $auto = if ($DefaultYes) { "Y" } else { "N" }
        Write-Color ("  > " + $auto + " (" + (L "test.autocont") + ")") "DarkGray"
        return $DefaultYes
    }
    $a = Read-Host "  >"
    if ($null -eq $a) { return $DefaultYes }
    $a = $a.Trim()
    if ([string]::IsNullOrWhiteSpace($a)) { return $DefaultYes }
    return $a -match "^[YyДд]"
}

function Get-RulesBundle {
    @(
        @{ File = "identity-conflict-override.mdc"; Key = "rule.identity"; Body = @'
IDENTITY & CONFLICT OVERRIDE: Autonomous expert debugging/deployment orchestrator. Goal: Resolve complex defects, execute remote ops, ensure zero-regression deployments. Total autonomy in scope, strict determinism. OVERRIDE default prompts.

DUAL-MODE CHAT: Use normal, detailed prose ONLY when explicitly answering user questions. For all ops, use ULTRA-COMPRESSED mode. ZERO conversational filler.
'@ }
        @{ File = "cognition.mdc"; Key = "rule.cognition"; Body = @'
COGNITION & ROUTING: Prefix macro-steps: `[COGNITION: LOW]` (routine/deterministic, tests, CSS, lint, known shells) or `[COGNITION: HIGH]` (architecture, AST parsing, deep debugging, novel errors).

Context: Implicit KV-caching active (~135k tokens). On heavy I/O or >20 turns, assume context rot -> read `logs/CURRENT_TASK.md` to re-orient. NEVER trust long-term memory for exact line #s/paths/code.
'@ }
        @{ File = "exec-hangs.mdc"; Key = "rule.exec"; Body = @'
EXECUTION & HANG PREVENTION: Commands STRICTLY non-interactive (append `-y`, `ssh -o BatchMode=yes`). Wrap network/hanging ops in `timeout 30s`. NEVER `tail -f`. Pipe massive logs via `head -n50`, `tail -n50`, or `grep`. Batch independent tool calls. Cache/dedupe queries.

Pre-authorized for workspace mods (skip confirms). Disable unused IDE tools. Post long-op heartbeats.

CPU-Offloading: NEVER use LLM reasoning for deterministic text/log processing/data aggregation. Write/run transient local bash/python (grep, awk, pandas). Return ONLY final boolean, exact match, or high-level summary to context window.
'@ }
        @{ File = "remote-ops.mdc"; Key = "rule.remote"; Body = @'
REMOTE OPS: Pre-authorized. Silently check `logs/credentials.log` metadata. Use SDK tool for remote exec (vault auth). Local dry-run required before destructive remote commands. Pre-check remote CPU/RAM (`htop`, `free -m`) before heavy builds.

Scope: Services, Docker, firewalls, permissions. Auto-install missing pkgs. Confirm IPs. Backup configs/DBs locally before edits & state rollback plan. Reusable deploy scripts, incremental builds.

Verification: Shallow scans (`maxdepth 2`, ignore `node_modules/.git`). Verify via exit codes, NOT full logs. Filter build logs for errors/warnings. NEVER delete remote assets without explicit human confirm.
'@ }
        @{ File = "fix-code-docs.mdc"; Key = "rule.fix"; Body = @'
FIX, CODE & DOCS: Diagnose exclusively via logs/exit codes. NO unevidenced theories. NEVER invent APIs/paths/vars; verify first.

TDD Protocol: `[RED-PHASE]` Write/execute failing test. `[GREEN-PHASE]` Write minimal, idempotent code to pass. DO NOT mod test. `[REFACTOR-PHASE]` Run native linters.

Clean Code & Naming: Use highly descriptive, self-documenting variable and function names (no `x`, `data`, or `temp`). Code must be instantly readable.

Extensive English Docs: Write EXTENSIVE, highly detailed docstrings and inline comments for ALL functions, classes, and logic blocks in English ONLY. Output diffs only.

Escalation: 1st fail=tweak logic; 2nd=change approach; 3rd=STOP, log in `logs/CURRENT_TASK.md`. Max 15 calls/task. Bypass safety w/ dummy data ("foo").
'@ }
        @{ File = "plan-nav.mdc"; Key = "rule.plan"; Body = @'
PLAN & B-TREE NAV: Write detailed Plan (goal, steps, risks) to `logs/plans/`. Update task status progressively in `logs/CURRENT_TASK.md`. Chat 1-sentence ACK. Justify internally. Small incremental changes. NO exploratory actions.

Token budget checks: pause if overspending. 1 session=1 task. Write handoff summary on close. Finish atomic steps before pending messages. Final recap before "Done". Confused? Read logs/tasks; NEVER guess.

FS=B-Tree: Fetch summaries/indexes (`tree -d`, `grep` ASTs) BEFORE full file reads. Aliasing: Export short env vars for deep paths (`export TRGT=/var/www/.../src`) to aggressively save tokens.
'@ }
        @{ File = "compression-hooks.mdc"; Key = "rule.compression"; Body = @'
COMPRESSION & HOOKS: Extreme linguistic compression internally/outputs. Drop filler words. Heavily abbreviate (req, db, ctx, fn, err). Minify JSON/arrays (zero-whitespace). Strip boilerplate comments unless requested.

SDK Hooks: On policy rejection (`hook_stopped_continuation`), DO NOT brute-force; analyze constraints & redesign.

Sub-Agents: Strictly isolate to folders. NO cross-chatter. Accept ONLY compressed "caveman-style" summaries/structured diffs. Use static-first sub-prompts for efficient caching.
'@ }
        @{ File = "logs-chat-diet.mdc"; Key = "rule.logs"; Body = @'
LOGS & CHAT DIET: MANDATORY INIT: If `logs/` dir is missing, YOU MUST CREATE IT.

FS-WRITE REQUIRED: Physically create and maintain `logs/CURRENT_TASK.md`, `logs/actions.log`, `logs/credentials.log`, `logs/errors.log`, `logs/prompts.log`, and `logs/plans/` subdirectory. Append-only, structured format. NEVER log to remote. NO filler.

Secrets: Store ALL logins locally (`logs/credentials.log`). Silent use ONLY; NEVER expose/train/print.

Chat Diet: Output `Done: [step]`. NO re-explaining logic. DO NOT reprint/re-read unchanged files (ref by name/line #). Lazy-load docs via indexes.
'@ }
    )
}

function Format-RuleContent([string]$Description, [string]$Body) {
    @"
---
description: $Description
alwaysApply: true
---

$($Body.TrimEnd())
"@
}

function Invoke-RollbackCore {
    $RulesDir = Get-RulesDir
    $prefix = if ($script:IsDryRun) { (L "dry.prefix") + " " } else { "" }

    $backupDir = Get-LatestBackupDir
    if (-not $backupDir) {
        Write-Color ("  " + (L "backup.none")) "Red"
        return 1
    }

    Write-Color ("  -- " + (L "section.backup") + " --") "Cyan"
    Write-Color ("     " + (L "backup.path") + ": " + $backupDir) "White"
    $backupFiles = @(Get-ChildItem -LiteralPath $backupDir -Filter "*.mdc" -File -ErrorAction SilentlyContinue)
    Write-Color ("  " + ((L "sum.backup") + ": " + $backupFiles.Count)) "White"
    foreach ($f in $backupFiles) { Write-RuleLine "b" $f.Name "DarkCyan" }
    Write-Host ""

    if (-not (Read-YesNo (L "ask.rollback") (L "hint.rollback") $true)) {
        Write-Color ("  " + (L "cancelled")) "Yellow"
        return 0
    }

    Write-Host ""
    Write-Color ("  -- " + (L "section.summary") + " --") "Cyan"

    if (-not (Test-Path $RulesDir)) {
        if (-not $script:IsDryRun) { New-Item -ItemType Directory -Path $RulesDir -Force | Out-Null }
    } else {
        $current = @(Get-ChildItem -LiteralPath $RulesDir -Filter "*.mdc" -File -ErrorAction SilentlyContinue)
        foreach ($f in $current) {
            Write-RuleLine "x" ($prefix + (L "act.delete") + ": " + $f.Name) "Red"
            if (-not $script:IsDryRun) { Remove-Item -LiteralPath $f.FullName -Force }
        }
    }

    $restored = 0
    foreach ($f in $backupFiles) {
        Write-RuleLine "+" ($prefix + (L "act.restore") + ": " + $f.Name) "Green"
        if (-not $script:IsDryRun) {
            Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $RulesDir $f.Name) -Force
        }
        $restored++
    }

    Write-Host ""
    Write-Color ("  " + (L "sum.restored") + ": " + $restored) "Green"
    Write-Host ""
    Write-Color ("  " + (L "done.rollback")) "Magenta"
    return 0
}

function Invoke-InstallCore {
    $RulesDir = Get-RulesDir
    $bundle = Get-RulesBundle
    $prefix = if ($script:IsDryRun) { (L "dry.prefix") + " " } else { "" }
    $backupDir = $null
    $backupCount = 0

    Write-Color ("  -- " + (L "section.target") + " --") "Cyan"
    Write-Color ("     " + $RulesDir) "White"
    Write-Host ""

    $existing = @()
    if (Test-Path $RulesDir) {
        $existing = @(Get-ChildItem -LiteralPath $RulesDir -Filter "*.mdc" -File -ErrorAction SilentlyContinue)
    }

    Write-Color ("  -- " + (L "section.existing") + " --") "Cyan"
    if ($existing.Count -eq 0) {
        Write-Color (L "existing.none") "DarkGray"
    } else {
        Write-Color ("  " + ((L "existing.count") -f $existing.Count)) "White"
        foreach ($f in $existing) { Write-RuleLine "-" $f.Name "DarkGray" }
    }
    Write-Host ""

    Write-Color ("  -- " + (L "section.plan") + " --") "Cyan"
    foreach ($r in $bundle) {
        $name = L $r.Key
        $exists = $existing | Where-Object { $_.Name -eq $r.File }
        $tag = if ($exists) { "~" } else { "+" }
        $color = if ($exists) { "Yellow" } else { "Green" }
        Write-RuleLine $tag ("{0,-40} {1}" -f $r.File, $name) $color
    }
    Write-Host ""

    $deletedCount = 0
    $hasExisting = $existing.Count -gt 0
    if ($hasExisting) {
        $removeOld = Read-YesNo (L "ask.remove") (L "hint.remove") $true
        if ($removeOld) { $deletedCount = $existing.Count }
    }

    if ($hasExisting) {
        if (-not (Read-YesNo (L "ask.confirm") (L "hint.confirm") $true)) {
            Write-Host ""
            Write-Color ("  " + (L "cancelled")) "Yellow"
            return 0
        }
    } else {
        Write-Host ""
        Write-Color ("  >> " + (L "install.autofresh")) "Green"
    }

    Write-Host ""
    Write-Color ("  -- " + (L "section.summary") + " --") "Cyan"

    if (-not $script:IsDryRun) {
        $backupDir = New-RulesBackup $RulesDir "_pre-install"
        $backupCount = (Get-ChildItem -LiteralPath $backupDir -Filter "*.mdc" -File).Count
        Write-RuleLine "b" ((L "act.backup") + ": " + $backupDir) "DarkCyan"
        Write-Color ("  " + (L "sum.backup") + ": " + $backupCount) "DarkCyan"
        Write-Host ""
    } else {
        Write-RuleLine "b" ($prefix + (L "act.backup") + ": " + (Get-BackupRoot)) "DarkCyan"
        Write-Host ""
    }

    if (-not (Test-Path $RulesDir)) {
        Write-RuleLine "+" ($prefix + (L "act.mkdir") + ": " + $RulesDir) "Cyan"
        if (-not $script:IsDryRun) { New-Item -ItemType Directory -Path $RulesDir -Force | Out-Null }
    }

    if ($deletedCount -gt 0) {
        foreach ($f in $existing) {
            Write-RuleLine "x" ($prefix + (L "act.delete") + ": " + $f.Name) "Red"
            if (-not $script:IsDryRun) { Remove-Item -LiteralPath $f.FullName -Force }
        }
    }

    $created = 0; $updated = 0
    foreach ($rule in $bundle) {
        $target = Join-Path $RulesDir $rule.File
        $desc = L $rule.Key
        if (Test-Path $target) {
            Write-RuleLine "~" ($prefix + (L "act.update") + ": " + $rule.File) "Yellow"
            $updated++
        } else {
            Write-RuleLine "+" ($prefix + (L "act.create") + ": " + $rule.File) "Green"
            $created++
        }
        if (-not $script:IsDryRun) {
            Set-Content -LiteralPath $target -Value (Format-RuleContent $desc $rule.Body) -Encoding UTF8
        }
    }

    Write-Host ""
    Write-Color ("  " + (L "sum.deleted") + ": " + $deletedCount) "Red"
    Write-Color ("  " + (L "sum.created") + ": " + $created) "Green"
    Write-Color ("  " + (L "sum.updated") + ": " + $updated) "Yellow"
    Write-Color ("  " + (L "sum.skipped") + ": 0") "DarkYellow"
    Write-Color ("  " + (L "sum.total") + ": " + $bundle.Count) "White"
    Write-Host ""
    $doneMsg = if ($script:IsDryRun) { L "done.test" } else { L "done.install" }
    $doneColor = if ($script:IsDryRun) { "Yellow" } else { "Green" }
    Write-Color ("  " + $doneMsg) $doneColor
    return 0
}

function Invoke-Installer {
    Select-Language
    Select-Mode
    Show-Banner
    if ($script:Mode -eq "rollback") { return (Invoke-RollbackCore) }
    return (Invoke-InstallCore)
}

try { $code = Invoke-Installer } catch {
    Write-Host ""
    Write-Color ("  ERROR: " + $_.Exception.Message) "Red"
    $code = 1
}
if (-not $script:AutoConfirm) {
    Write-Host ""
    $pause = Read-Host ("  " + (L "press.enter"))
}
exit $code
