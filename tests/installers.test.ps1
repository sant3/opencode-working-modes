param(
    [Parameter(Mandatory = $true)]
    [string]$RepositoryRoot
)

$ErrorActionPreference = 'Stop'
$sourceSkill = Join-Path $RepositoryRoot 'skills/working-modes/SKILL.md'
$sourceCommands = Join-Path $RepositoryRoot 'commands'
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("opencode-working-modes-test-" + [guid]::NewGuid())
$projectRoot = Join-Path $tempRoot 'project'
$globalRoot = Join-Path $tempRoot 'home/.config/opencode'

function Assert-Equal([string]$Expected, [string]$Actual, [string]$Message) {
    if ($Expected -cne $Actual) {
        throw "$Message`nExpected: $Expected`nActual:   $Actual"
    }
}

function Invoke-Installer([string[]]$Arguments) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepositoryRoot 'install.ps1') @Arguments | Out-Host
    return $LASTEXITCODE
}

try {
    New-Item -ItemType Directory -Path $projectRoot -Force | Out-Null

    if ((Invoke-Installer @('-Project', '-ProjectDir', $projectRoot)) -ne 0) { throw 'PowerShell project install failed.' }

    $installedSkill = Join-Path $projectRoot '.opencode/skills/working-modes/SKILL.md'
    Assert-Equal (Get-Content -Raw -LiteralPath $sourceSkill) (Get-Content -Raw -LiteralPath $installedSkill) 'Project skill differs from source.'

    foreach ($command in @('auto.md', 'manual.md', 'plan.md')) {
        Assert-Equal (Get-Content -Raw -LiteralPath (Join-Path $sourceCommands $command)) (Get-Content -Raw -LiteralPath (Join-Path $projectRoot ".opencode/commands/$command")) "Project command $command differs from source."
    }

    $collision = Join-Path $projectRoot '.opencode/commands/auto.md'
    Set-Content -LiteralPath $collision -Value 'preserve-existing' -NoNewline
    if ((Invoke-Installer @('-Project', '-ProjectDir', $projectRoot)) -eq 0) { throw 'PowerShell installer unexpectedly overwrote existing files without -Force.' }
    Assert-Equal 'preserve-existing' (Get-Content -Raw -LiteralPath $collision) 'PowerShell installer changed an existing file without --force.'
    Assert-Equal (Get-Content -Raw -LiteralPath (Join-Path $sourceCommands 'manual.md')) (Get-Content -Raw -LiteralPath (Join-Path $projectRoot '.opencode/commands/manual.md')) 'Installer partially copied files before detecting a collision.'

    if ((Invoke-Installer @('-Project', '-ProjectDir', $projectRoot, '-Force')) -ne 0) { throw 'PowerShell forced project install failed.' }
    Assert-Equal (Get-Content -Raw -LiteralPath (Join-Path $sourceCommands 'auto.md')) (Get-Content -Raw -LiteralPath $collision) 'PowerShell --force did not replace an existing file.'

    New-Item -ItemType Directory -Path (Join-Path $tempRoot 'home') -Force | Out-Null
    $previousHome = $env:HOME
    $previousUserProfile = $env:USERPROFILE
    $previousConfigHome = $env:XDG_CONFIG_HOME
    $env:HOME = Join-Path $tempRoot 'home'
    $env:USERPROFILE = Join-Path $tempRoot 'home'
    $env:XDG_CONFIG_HOME = Join-Path $tempRoot 'home/.config'
    if ((Invoke-Installer @('-Global')) -ne 0) { throw 'PowerShell global install failed.' }
    Assert-Equal (Get-Content -Raw -LiteralPath $sourceSkill) (Get-Content -Raw -LiteralPath (Join-Path $globalRoot 'skills/working-modes/SKILL.md')) 'Global skill differs from source.'
    $env:HOME = $previousHome
    $env:USERPROFILE = $previousUserProfile
    $env:XDG_CONFIG_HOME = $previousConfigHome

    Write-Output 'PowerShell installer tests passed.'
}
finally {
    $env:HOME = $previousHome
    $env:USERPROFILE = $previousUserProfile
    $env:XDG_CONFIG_HOME = $previousConfigHome
    Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}
