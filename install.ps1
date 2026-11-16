param(
    [switch]$Global,
    [switch]$Project,
    [string]$ProjectDir = (Get-Location).Path,
    [switch]$Force,
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

if ($Help) {
    @'
Usage: .\install.ps1 [-Global | -Project] [-ProjectDir PATH] [-Force]

  -Global      Install for the current user in ~/.config/opencode (default)
  -Project     Install in .opencode under the current project directory
  -ProjectDir  Project root to use with -Project (default: current directory)
  -Force       Replace existing files
'@ | Write-Output
    exit 0
}

if ($Global -and $Project) {
    throw 'Choose either -Global or -Project, not both.'
}

if (-not $Global -and -not $Project -and [string]::IsNullOrWhiteSpace($env:HOME) -and [string]::IsNullOrWhiteSpace($env:USERPROFILE)) {
    throw 'Could not determine the home directory for a global installation.'
}

$mode = if ($Project) { 'project' } else { 'global' }
$files = @(
    'skills/working-modes/SKILL.md',
    'commands/auto.md',
    'commands/manual.md',
    'commands/plan.md'
)
$scriptDirectory = $PSScriptRoot
$temporaryDirectory = $null
$remoteFiles = $false

if ([string]::IsNullOrWhiteSpace($scriptDirectory) -or
    -not (Test-Path -LiteralPath (Join-Path $scriptDirectory $files[0])) -or
    -not (Test-Path -LiteralPath (Join-Path $scriptDirectory $files[1]))) {
    $baseUrl = if ($env:OPENCODE_WORKING_MODES_BASE_URL) {
        $env:OPENCODE_WORKING_MODES_BASE_URL.TrimEnd('/')
    } else {
        'https://raw.githubusercontent.com/sant3/opencode-working-modes/main'
    }
    $temporaryDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path $temporaryDirectory | Out-Null
    $scriptDirectory = $temporaryDirectory
    $remoteFiles = $true
    foreach ($file in $files) {
        $target = Join-Path $scriptDirectory $file
        New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
        Invoke-WebRequest -Uri "$baseUrl/$($file.Replace('\', '/'))" -OutFile $target
    }
}

try {
    if ($remoteFiles) {
        $mode = if ($Global) { 'global' } elseif ($Project) { 'project' } else { 'global' }
    }

    if ($mode -eq 'global') {
        $homeDirectory = if ($env:HOME) { $env:HOME } else { $env:USERPROFILE }
        $destination = Join-Path $homeDirectory '.config/opencode'
    } else {
        $destination = Join-Path $ProjectDir '.opencode'
    }

    foreach ($file in $files) {
        $target = Join-Path $destination $file
        if ((Test-Path -LiteralPath $target) -and -not $Force) {
            throw "Refusing to overwrite existing file: $target (use -Force)"
        }
    }

    foreach ($file in $files) {
        $target = Join-Path $destination $file
        New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
        Copy-Item -LiteralPath (Join-Path $scriptDirectory $file) -Destination $target -Force
    }

    Write-Output "Installed working modes in $destination"
}
finally {
    if ($temporaryDirectory -and (Test-Path -LiteralPath $temporaryDirectory)) {
        Remove-Item -LiteralPath $temporaryDirectory -Recurse -Force
    }
}
