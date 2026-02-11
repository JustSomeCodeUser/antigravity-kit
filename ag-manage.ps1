<#
.SYNOPSIS
    Antigravity Kit Management Script
    Used to install or update the kit in other projects.

.DESCRIPTION
    This script allows you to "install" your custom Antigravity Kit into other project directories.
    It copies the core configuration files (.agent folder and GEMINI.md) while avoiding
    conflicts with project-specific files like package.json or .git.

.EXAMPLE
    .\ag-manage.ps1 -Install -Target "C:\Projects\MyNewApp"
    Installs the kit into the specified target directory.

.EXAMPLE
    .\ag-manage.ps1 -Update -Target "C:\Projects\MyNewApp"
    Updates the kit in the specified target directory (overwrites .agent and GEMINI.md).
#>

param (
    [Parameter(Mandatory=$true, ParameterSetName="Install")]
    [switch]$Install,

    [Parameter(Mandatory=$true, ParameterSetName="Update")]
    [switch]$Update,

    [Parameter(Mandatory=$true)]
    [string]$Target
)

$SourceDir = $PSScriptRoot
$AgentDir = Join-Path $SourceDir ".agent"
$GeminiFile = Join-Path $SourceDir "GEMINI.md"

# Validate Source
if (-not (Test-Path $AgentDir)) {
    Write-Error "Critical Error: .agent folder not found in $SourceDir"
    exit 1
}
if (-not (Test-Path $GeminiFile)) {
    Write-Error "Critical Error: GEMINI.md not found in $SourceDir"
    exit 1
}

# Validate Target
if (-not (Test-Path $Target)) {
    Write-Host "Target directory does not exist. Creating..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $Target -Force | Out-Null
}

$TargetAgentDir = Join-Path $Target ".agent"
$TargetGeminiFile = Join-Path $Target "GEMINI.md"

# Execution Logic
if ($Install -or $Update) {
    Write-Host "🚀 Installing Antigravity Kit to: $Target" -ForegroundColor Cyan

    # 1. Copy .agent folder
    Write-Host "   📂 Copying .agent folder..." -NoNewline
    if (Test-Path $TargetAgentDir) {
        if ($Update) {
            Write-Host " (Updating)" -ForegroundColor Yellow
            Copy-Item -Path $AgentDir -Destination $Target -Recurse -Force
        } else {
            Write-Host " (Exists - Skipping, use -Update to overwrite)" -ForegroundColor Yellow
        }
    } else {
        Copy-Item -Path $AgentDir -Destination $Target -Recurse
        Write-Host " Done." -ForegroundColor Green
    }

    # 2. Copy GEMINI.md
    Write-Host "   📄 Copying GEMINI.md..." -NoNewline
    Copy-Item -Path $GeminiFile -Destination $Target -Force
    Write-Host " Done." -ForegroundColor Green

    # 3. Success Message
    Write-Host "`n✅ Installation Complete!" -ForegroundColor Green
    Write-Host "   You can now use your custom Antigravity Agents in $Target"
    Write-Host "   Make sure to update your .gitignore (see README.md)"
}
