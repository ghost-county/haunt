#Requires -Version 5.1
<#
.SYNOPSIS
    Haunt Setup Script for Windows

.DESCRIPTION
    This script summons the Haunt framework including:
    - Spirit agents in ~/.claude/agents/
    - Haunt skills from Haunt/skills/
    - Infrastructure verification
    - Directory structure creation

.PARAMETER Scope
    Summoning scope: 'project' (default), 'global', or 'both'

.PARAMETER AgentsOnly
    Only summon spirit agents

.PARAMETER SkillsOnly
    Only conjure project-specific skills

.PARAMETER Verify
    Only verify existing haunt, don't modify

.PARAMETER Fix
    Exorcise issues found during verification

.PARAMETER DryRun
    Show what would be done without executing

.PARAMETER SkipPrereqs
    Skip prerequisite divination

.PARAMETER NoBackup
    Skip backup of existing spirits

.PARAMETER NoMcp
    Skip MCP server channeling

.PARAMETER Verbose
    Show detailed output during execution

.PARAMETER Cleanup
    Delete cloned repo after setup (for remote installation)

.EXAMPLE
    .\setup-haunt.ps1
    Full setup to project-local .claude/

.EXAMPLE
    .\setup-haunt.ps1 -Scope global
    Install to user-level ~/.claude/

.EXAMPLE
    .\setup-haunt.ps1 -DryRun
    Preview what would be installed

.EXAMPLE
    .\setup-haunt.ps1 -Verify -Fix
    Verify and fix any issues

.EXAMPLE
    irm https://raw.githubusercontent.com/ghost-county/ghost-county/main/Haunt/scripts/setup-haunt.ps1 | iex
    Remote installation via PowerShell

.NOTES
    Author: Ghost County
    Version: 2.0.0
    Requires: PowerShell 5.1+, Git, Node.js 18+
#>

[CmdletBinding()]
param(
    [ValidateSet('project', 'global', 'both')]
    [string]$Scope = 'project',

    [switch]$AgentsOnly,
    [switch]$SkillsOnly,
    [switch]$Verify,
    [switch]$Fix,
    [switch]$DryRun,
    [switch]$SkipPrereqs,
    [switch]$NoBackup,
    [switch]$NoMcp,
    [switch]$Cleanup,
    [switch]$Help
)

# ============================================================================
# CONFIGURATION
# ============================================================================

$ErrorActionPreference = 'Stop'

# GitHub repo for remote installation
$GitHubRepoUrl = "https://github.com/ghost-county/ghost-county.git"
$GitHubRepoBranch = "main"

# Paths
$UserHome = $env:USERPROFILE
$GlobalClaudeDir = Join-Path $UserHome ".claude"
$GlobalAgentsDir = Join-Path $GlobalClaudeDir "agents"
$GlobalSkillsDir = Join-Path $GlobalClaudeDir "skills"
$GlobalCommandsDir = Join-Path $GlobalClaudeDir "commands"
$GlobalRulesDir = Join-Path $GlobalClaudeDir "rules"
$GlobalSettingsFile = Join-Path $GlobalClaudeDir "settings.json"

$ProjectClaudeDir = Join-Path (Get-Location) ".claude"
$ProjectAgentsDir = Join-Path $ProjectClaudeDir "agents"
$ProjectSkillsDir = Join-Path $ProjectClaudeDir "skills"
$ProjectCommandsDir = Join-Path $ProjectClaudeDir "commands"
$ProjectRulesDir = Join-Path $ProjectClaudeDir "rules"
$ProjectSettingsFile = Join-Path $ProjectClaudeDir "settings.json"

$HauntDir = Join-Path (Get-Location) ".haunt"

# Script location detection
$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
$RepoRoot = Split-Path (Split-Path $ScriptDir -Parent) -Parent
$SourceAgentsDir = Join-Path (Split-Path $ScriptDir -Parent) "agents"
$SourceSkillsDir = Join-Path (Split-Path $ScriptDir -Parent) "skills"
$SourceCommandsDir = Join-Path (Split-Path $ScriptDir -Parent) "commands"
$SourceRulesDir = Join-Path (Split-Path $ScriptDir -Parent) "rules"

# Remote execution tracking
$RemoteCloneDir = $null
$RunningFromRemote = $false

# ============================================================================
# OUTPUT FUNCTIONS
# ============================================================================

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Write-Info {
    param([string]$Message)
    Write-Host "[i] " -ForegroundColor Cyan -NoNewline
    Write-Host $Message
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[!] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

function Write-Err {
    param([string]$Message)
    Write-Host "[X] " -ForegroundColor Red -NoNewline
    Write-Host $Message
}

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host ("=" * 50) -ForegroundColor Magenta
    Write-Host "  $Title" -ForegroundColor Magenta
    Write-Host ("=" * 50) -ForegroundColor Magenta
    Write-Host ""
}

function Show-Banner {
    $banner = @"

                               .     .
                            .  |\-^-/|  .
                           /| } O.=.O { |\

         ##   ##    ###    ##   ##  ###  ##  ########
         ##   ##   ## ##   ##   ##  #### ##     ##
         #######  ##   ##  ##   ##  ## ####     ##
         ##   ##  #######  ##   ##  ##  ###     ##
         ##   ##  ##   ##   #####   ##   ##     ##

                    G H O S T   C O U N T Y
                      Summon Your Dev Team

"@
    Write-Host $banner -ForegroundColor Magenta
}

function Show-Help {
    $helpText = @"
USAGE:
    .\setup-haunt.ps1 [OPTIONS]

DESCRIPTION:
    Haunt framework setup script for Windows. By default, summons to project-local .claude/:

    - Spirit agents to .claude/agents/ (use -Scope global for user-level)
    - Haunt methodology skills from Haunt/skills/
    - Verifies spiritual infrastructure (MCP servers)
    - Manifests required directory structure (.haunt/)
    - Ensures idempotent execution (safe to run multiple times)

OPTIONS:
    -Help               Show this help message
    -DryRun             Show what would be done without executing
    -Scope <value>      Summoning scope: project (default), global, or both
    -AgentsOnly         Only summon spirit agents
    -SkillsOnly         Only conjure project-specific skills
    -Verify             Only verify existing haunt, don't modify
    -Fix                Exorcise issues found during verification
    -SkipPrereqs        Skip prerequisite divination
    -NoBackup           Skip backup of existing spirits
    -NoMcp              Skip MCP server channeling
    -Cleanup            Delete cloned repo after setup (for remote installation)
    -Verbose            Show detailed output

WINDOWS INSTALLATION RECOMMENDATIONS:
    RECOMMENDED: Use Git Bash (more reliable)
        git clone https://github.com/ghost-county/ghost-county.git
        cd ghost-county
        bash Haunt/scripts/setup-haunt.sh
        cd .. && rm -rf ghost-county

    ALTERNATIVE: PowerShell (if Git Bash not available)
        # Quick install via PowerShell
        irm https://raw.githubusercontent.com/ghost-county/ghost-county/main/Haunt/scripts/setup-haunt.ps1 | iex

        # Or download and run
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ghost-county/ghost-county/main/Haunt/scripts/setup-haunt.ps1" -OutFile setup-haunt.ps1
        .\setup-haunt.ps1

    TROUBLESHOOTING:
        If you get "Failed to clone repository" errors, see:
        https://github.com/ghost-county/ghost-county/blob/main/Haunt/SETUP-GUIDE.md#issue-11-failed-to-clone-repository-during-remote-installation

EXAMPLES:
    # Full setup (default: project-local to .claude/)
    .\setup-haunt.ps1

    # Summon to global/user-level
    .\setup-haunt.ps1 -Scope global

    # Summon to both global and project scopes
    .\setup-haunt.ps1 -Scope both

    # Preview what would be installed
    .\setup-haunt.ps1 -DryRun

    # Only summon agents
    .\setup-haunt.ps1 -AgentsOnly

    # Verify existing setup
    .\setup-haunt.ps1 -Verify

    # Verify and fix issues
    .\setup-haunt.ps1 -Verify -Fix

EXIT CODES:
    0    Success
    1    General error
    2    Invalid arguments
    3    Missing dependencies
    4    Verification failed

"@
    Write-Host $helpText
}

# ============================================================================
# REMOTE EXECUTION SUPPORT
# ============================================================================

function Test-LocalResources {
    return (Test-Path $SourceAgentsDir) -and (Test-Path $SourceSkillsDir)
}

function Get-ClonedRepo {
    $cloneDir = Join-Path $env:TEMP "haunt-setup-$PID"

    Write-Info "Remote execution detected - cloning repository..."

    # Check for git
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Err "git is required for remote installation"
        Write-Err "Please install git and try again"
        exit 3
    }

    # Clone the repo
    try {
        git clone --depth 1 --branch $GitHubRepoBranch $GitHubRepoUrl $cloneDir 2>&1 | Out-Null
        Write-Success "Repository cloned to $cloneDir"
    }
    catch {
        Write-Err "Failed to clone repository from $GitHubRepoUrl"
        exit 3
    }

    return $cloneDir
}

function Remove-ClonedRepo {
    if ($RemoteCloneDir -and (Test-Path $RemoteCloneDir)) {
        if ($Cleanup) {
            Write-Info "Cleaning up cloned repository..."
            Remove-Item -Path $RemoteCloneDir -Recurse -Force
            Write-Success "Removed $RemoteCloneDir"
        }
        else {
            Write-Info "Cloned repository kept at: $RemoteCloneDir"
            Write-Info "To remove it later, run: Remove-Item -Recurse '$RemoteCloneDir'"
        }
    }
}

function Initialize-Resources {
    # Check if we have local resources
    if (-not (Test-LocalResources)) {
        $script:RunningFromRemote = $true
        $script:RemoteCloneDir = Get-ClonedRepo
        $script:SourceAgentsDir = Join-Path $RemoteCloneDir "Haunt\agents"
        $script:SourceSkillsDir = Join-Path $RemoteCloneDir "Haunt\skills"
        $script:SourceCommandsDir = Join-Path $RemoteCloneDir "Haunt\commands"
        $script:SourceRulesDir = Join-Path $RemoteCloneDir "Haunt\rules"
    }
}

# ============================================================================
# PHASE 1: PREREQUISITES CHECK
# ============================================================================

function Test-Prerequisites {
    Write-Section "Phase 1: Divining Prerequisites"

    if ($SkipPrereqs) {
        Write-Warn "Skipping prerequisite checks (-SkipPrereqs flag set)"
        return $true
    }

    $criticalMissing = @()
    $optionalMissing = @()
    $warnings = @()

    # Check: Git
    $git = Get-Command git -ErrorAction SilentlyContinue
    if (-not $git) {
        $criticalMissing += "git"
        Write-Err "git: NOT FOUND"
        Write-Info "  Install: https://git-scm.com/download/win"
        Write-Info "  Or: winget install Git.Git"
    }
    else {
        $gitVersion = (git --version) -replace 'git version ', ''
        Write-Success "git: $gitVersion"

        # Check git configuration
        $gitUser = git config --get user.name 2>$null
        if (-not $gitUser) {
            $warnings += "Git user.name not configured"
            Write-Warn "git user.name: NOT CONFIGURED"
            Write-Info '  Configure: git config --global user.name "Your Name"'
        }
        else {
            Write-Success "git user.name: $gitUser"
        }

        $gitEmail = git config --get user.email 2>$null
        if (-not $gitEmail) {
            $warnings += "Git user.email not configured"
            Write-Warn "git user.email: NOT CONFIGURED"
            Write-Info '  Configure: git config --global user.email "your.email@example.com"'
        }
        else {
            Write-Success "git user.email: $gitEmail"
        }
    }

    # Check: Python 3.11+
    $python = Get-Command python -ErrorAction SilentlyContinue
    if (-not $python) {
        $python = Get-Command python3 -ErrorAction SilentlyContinue
    }
    if (-not $python) {
        $criticalMissing += "python"
        Write-Err "Python 3: NOT FOUND"
        Write-Info "  Install: https://python.org/downloads/"
        Write-Info "  Or: winget install Python.Python.3.11"
    }
    else {
        $pythonVersion = & $python.Source --version 2>&1 | Select-String -Pattern '\d+\.\d+\.\d+' | ForEach-Object { $_.Matches[0].Value }
        $versionParts = $pythonVersion -split '\.'
        $major = [int]$versionParts[0]
        $minor = [int]$versionParts[1]

        if ($major -lt 3 -or ($major -eq 3 -and $minor -lt 11)) {
            $criticalMissing += "python3.11+"
            Write-Err "Python 3: $pythonVersion (requires 3.11+)"
            Write-Info "  Install: https://python.org/downloads/"
        }
        else {
            Write-Success "Python 3: $pythonVersion"
        }
    }

    # Check: Node.js 18+
    $node = Get-Command node -ErrorAction SilentlyContinue
    if (-not $node) {
        $criticalMissing += "node"
        Write-Err "Node.js: NOT FOUND"
        Write-Info "  Install: https://nodejs.org/"
        Write-Info "  Or: winget install OpenJS.NodeJS.LTS"
    }
    else {
        $nodeVersion = (node --version) -replace 'v', ''
        $nodeMajor = [int]($nodeVersion -split '\.')[0]

        if ($nodeMajor -lt 18) {
            $criticalMissing += "node18+"
            Write-Err "Node.js: $nodeVersion (requires 18+)"
            Write-Info "  Install: https://nodejs.org/"
        }
        else {
            Write-Success "Node.js: $nodeVersion"
        }
    }

    # Check: Claude Code CLI
    $claude = Get-Command claude -ErrorAction SilentlyContinue
    if (-not $claude) {
        $criticalMissing += "claude"
        Write-Err "Claude Code CLI: NOT FOUND"
        Write-Info "  Install: npm install -g @anthropic-ai/claude-code"
    }
    else {
        try {
            $claudeVersion = claude --version 2>$null
            if (-not $claudeVersion) { $claudeVersion = "installed" }
        }
        catch {
            $claudeVersion = "installed"
        }
        Write-Success "Claude Code CLI: $claudeVersion"
    }

    # Check: uv package manager (Optional)
    $uv = Get-Command uv -ErrorAction SilentlyContinue
    if (-not $uv) {
        $optionalMissing += "uv"
        Write-Warn "uv package manager: NOT FOUND (optional)"
        Write-Info "  Install: irm https://astral.sh/uv/install.ps1 | iex"
        Write-Info "  Note: Required for MCP server management"
    }
    else {
        $uvVersion = (uv --version) -replace 'uv ', ''
        Write-Success "uv package manager: $uvVersion"
    }

    Write-Host ""

    # Report critical missing dependencies
    if ($criticalMissing.Count -gt 0) {
        Write-Err "CRITICAL: Missing required dependencies ($($criticalMissing.Count)):"
        foreach ($dep in $criticalMissing) {
            Write-Host "  - $dep"
        }
        Write-Host ""
        Write-Err "Setup cannot continue without critical dependencies."
        Write-Info "Install missing dependencies and re-run this script."
        exit 3
    }

    # Report optional missing dependencies
    if ($optionalMissing.Count -gt 0) {
        Write-Warn "OPTIONAL: Missing recommended dependencies ($($optionalMissing.Count)):"
        foreach ($dep in $optionalMissing) {
            Write-Host "  - $dep"
        }
        Write-Host ""
        Write-Warn "Setup will continue, but some features may be limited."
        Write-Host ""
    }

    # Report warnings
    if ($warnings.Count -gt 0) {
        Write-Warn "WARNINGS: Configuration issues found ($($warnings.Count)):"
        foreach ($warn in $warnings) {
            Write-Host "  - $warn"
        }
        Write-Host ""
    }

    Write-Success "All critical prerequisites satisfied"
    Write-Host ""
    return $true
}

# ============================================================================
# PHASE 2: AGENTS SETUP
# ============================================================================

function Install-AgentsToDirectory {
    param(
        [string]$TargetDir,
        [string]$BackupDir,
        [string]$ScopeName
    )

    Write-Info "Summoning to: $TargetDir"
    Write-Info "Source agents directory: $SourceAgentsDir"

    # Create target directory
    if (-not (Test-Path $TargetDir)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
            Write-Success "Created $TargetDir"
        }
        else {
            Write-Info "[DRY RUN] Would create $TargetDir"
        }
    }
    else {
        Write-Info "Directory already exists: $TargetDir"
    }

    # Backup existing agents
    if (-not $NoBackup) {
        $existingAgents = Get-ChildItem -Path $TargetDir -Filter "*.md" -ErrorAction SilentlyContinue
        if ($existingAgents.Count -gt 0) {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $backupPath = Join-Path $BackupDir $timestamp

            if (-not $DryRun) {
                New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
                Copy-Item -Path "$TargetDir\*.md" -Destination $backupPath -ErrorAction SilentlyContinue
                Write-Success "Backed up $($existingAgents.Count) existing agent(s) to $backupPath"
            }
            else {
                Write-Info "[DRY RUN] Would backup $($existingAgents.Count) agent(s) to $backupPath"
            }
        }
        else {
            Write-Info "No existing agents to backup"
        }
    }
    else {
        Write-Info "Skipping backup (-NoBackup flag set)"
    }

    # Copy agents
    $installedCount = 0
    $updatedCount = 0
    $unchangedCount = 0

    $sourceAgents = Get-ChildItem -Path $SourceAgentsDir -Filter "*.md" -ErrorAction SilentlyContinue
    foreach ($agentFile in $sourceAgents) {
        $destFile = Join-Path $TargetDir $agentFile.Name

        if (Test-Path $destFile) {
            # Compare files
            $sourceHash = (Get-FileHash $agentFile.FullName -Algorithm MD5).Hash
            $destHash = (Get-FileHash $destFile -Algorithm MD5).Hash

            if ($sourceHash -ne $destHash) {
                if (-not $DryRun) {
                    Copy-Item -Path $agentFile.FullName -Destination $destFile -Force
                    Write-Success "Updated $($agentFile.Name)"
                }
                else {
                    Write-Info "[DRY RUN] Would update $($agentFile.Name)"
                }
                $updatedCount++
            }
            else {
                Write-Info "Unchanged: $($agentFile.Name)"
                $unchangedCount++
            }
        }
        else {
            if (-not $DryRun) {
                Copy-Item -Path $agentFile.FullName -Destination $destFile
                Write-Success "Installed $($agentFile.Name)"
            }
            else {
                Write-Info "[DRY RUN] Would install $($agentFile.Name)"
            }
            $installedCount++
        }
    }

    Write-Host ""
    Write-Info "Agent installation summary for ${ScopeName}:"
    Write-Host "  - Installed: $installedCount new agent(s)"
    Write-Host "  - Updated:   $updatedCount agent(s)"
    Write-Host "  - Unchanged: $unchangedCount agent(s)"
}

function Install-Agents {
    Write-Section "Phase 2: Summoning Spirit Agents"

    switch ($Scope) {
        'global' {
            Install-AgentsToDirectory -TargetDir $GlobalAgentsDir -BackupDir "$GlobalAgentsDir.backup" -ScopeName "global"
        }
        'project' {
            Install-AgentsToDirectory -TargetDir $ProjectAgentsDir -BackupDir "$ProjectAgentsDir.backup" -ScopeName "project"
        }
        'both' {
            Install-AgentsToDirectory -TargetDir $GlobalAgentsDir -BackupDir "$GlobalAgentsDir.backup" -ScopeName "global"
            Write-Host ""
            Install-AgentsToDirectory -TargetDir $ProjectAgentsDir -BackupDir "$ProjectAgentsDir.backup" -ScopeName "project"
        }
    }
}

# ============================================================================
# PHASE 3: SKILLS SETUP
# ============================================================================

function Install-SkillsToDirectory {
    param(
        [string]$TargetDir,
        [string]$ScopeName
    )

    Write-Info "Conjuring skills to: $TargetDir"
    Write-Info "Source skills directory: $SourceSkillsDir"

    # Create target directory
    if (-not (Test-Path $TargetDir)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
            Write-Success "Created $TargetDir"
        }
        else {
            Write-Info "[DRY RUN] Would create $TargetDir"
        }
    }

    # Copy skill directories (only gco-* prefixed ones)
    $installedCount = 0
    $updatedCount = 0

    $sourceSkills = Get-ChildItem -Path $SourceSkillsDir -Directory -Filter "gco-*" -ErrorAction SilentlyContinue
    foreach ($skillDir in $sourceSkills) {
        $destDir = Join-Path $TargetDir $skillDir.Name

        if (Test-Path $destDir) {
            if (-not $DryRun) {
                Remove-Item -Path $destDir -Recurse -Force
                Copy-Item -Path $skillDir.FullName -Destination $destDir -Recurse
                Write-Success "Updated $($skillDir.Name)"
            }
            else {
                Write-Info "[DRY RUN] Would update $($skillDir.Name)"
            }
            $updatedCount++
        }
        else {
            if (-not $DryRun) {
                Copy-Item -Path $skillDir.FullName -Destination $destDir -Recurse
                Write-Success "Installed $($skillDir.Name)"
            }
            else {
                Write-Info "[DRY RUN] Would install $($skillDir.Name)"
            }
            $installedCount++
        }
    }

    Write-Host ""
    Write-Info "Skills installation summary for ${ScopeName}:"
    Write-Host "  - Installed: $installedCount new skill(s)"
    Write-Host "  - Updated:   $updatedCount skill(s)"
}

function Install-Skills {
    Write-Section "Phase 3: Conjuring Methodology Skills"

    switch ($Scope) {
        'global' {
            Install-SkillsToDirectory -TargetDir $GlobalSkillsDir -ScopeName "global"
        }
        'project' {
            Install-SkillsToDirectory -TargetDir $ProjectSkillsDir -ScopeName "project"
        }
        'both' {
            Install-SkillsToDirectory -TargetDir $GlobalSkillsDir -ScopeName "global"
            Write-Host ""
            Install-SkillsToDirectory -TargetDir $ProjectSkillsDir -ScopeName "project"
        }
    }
}

# ============================================================================
# PHASE 4: RULES SETUP
# ============================================================================

function Install-RulesToDirectory {
    param(
        [string]$TargetDir,
        [string]$ScopeName
    )

    Write-Info "Binding rules to: $TargetDir"

    if (-not (Test-Path $SourceRulesDir)) {
        Write-Info "No source rules directory found, skipping"
        return
    }

    # Create target directory
    if (-not (Test-Path $TargetDir)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
            Write-Success "Created $TargetDir"
        }
        else {
            Write-Info "[DRY RUN] Would create $TargetDir"
        }
    }

    # Copy rule files (only gco-* prefixed ones)
    $installedCount = 0
    $updatedCount = 0

    $sourceRules = Get-ChildItem -Path $SourceRulesDir -Filter "gco-*.md" -ErrorAction SilentlyContinue
    foreach ($ruleFile in $sourceRules) {
        $destFile = Join-Path $TargetDir $ruleFile.Name

        if (Test-Path $destFile) {
            $sourceHash = (Get-FileHash $ruleFile.FullName -Algorithm MD5).Hash
            $destHash = (Get-FileHash $destFile -Algorithm MD5).Hash

            if ($sourceHash -ne $destHash) {
                if (-not $DryRun) {
                    Copy-Item -Path $ruleFile.FullName -Destination $destFile -Force
                    Write-Success "Updated $($ruleFile.Name)"
                }
                else {
                    Write-Info "[DRY RUN] Would update $($ruleFile.Name)"
                }
                $updatedCount++
            }
        }
        else {
            if (-not $DryRun) {
                Copy-Item -Path $ruleFile.FullName -Destination $destFile
                Write-Success "Installed $($ruleFile.Name)"
            }
            else {
                Write-Info "[DRY RUN] Would install $($ruleFile.Name)"
            }
            $installedCount++
        }
    }

    Write-Host ""
    Write-Info "Rules installation summary for ${ScopeName}:"
    Write-Host "  - Installed: $installedCount new rule(s)"
    Write-Host "  - Updated:   $updatedCount rule(s)"
}

function Install-Rules {
    Write-Section "Phase 4: Binding Enforcement Rules"

    switch ($Scope) {
        'global' {
            Install-RulesToDirectory -TargetDir $GlobalRulesDir -ScopeName "global"
        }
        'project' {
            Install-RulesToDirectory -TargetDir $ProjectRulesDir -ScopeName "project"
        }
        'both' {
            Install-RulesToDirectory -TargetDir $GlobalRulesDir -ScopeName "global"
            Write-Host ""
            Install-RulesToDirectory -TargetDir $ProjectRulesDir -ScopeName "project"
        }
    }
}

# ============================================================================
# PHASE 4B: SLASH COMMANDS INSTALLATION
# ============================================================================

function Install-CommandsToDirectory {
    param(
        [string]$TargetDir,
        [string]$ScopeName
    )

    Write-Info "Inscribing slash commands to: $TargetDir"

    if (-not (Test-Path $SourceCommandsDir)) {
        Write-Warn "No source commands directory found, skipping"
        return
    }

    # Count source commands
    $sourceCommands = Get-ChildItem -Path $SourceCommandsDir -Filter "*.md" -ErrorAction SilentlyContinue
    if ($sourceCommands.Count -eq 0) {
        Write-Warn "No command files found in $SourceCommandsDir"
        return
    }
    Write-Info "Found $($sourceCommands.Count) command(s) to install"

    # Create target directory
    if (-not (Test-Path $TargetDir)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
            Write-Success "Created $TargetDir"
        }
        else {
            Write-Info "[DRY RUN] Would create $TargetDir"
        }
    }
    else {
        Write-Info "Directory already exists: $TargetDir"
    }

    # Copy command files
    $installedCount = 0
    $updatedCount = 0
    $unchangedCount = 0

    foreach ($commandFile in $sourceCommands) {
        $destFile = Join-Path $TargetDir $commandFile.Name

        if (Test-Path $destFile) {
            $sourceHash = (Get-FileHash $commandFile.FullName -Algorithm MD5).Hash
            $destHash = (Get-FileHash $destFile -Algorithm MD5).Hash

            if ($sourceHash -ne $destHash) {
                if (-not $DryRun) {
                    Copy-Item -Path $commandFile.FullName -Destination $destFile -Force
                    Write-Success "Updated $($commandFile.Name)"
                }
                else {
                    Write-Info "[DRY RUN] Would update $($commandFile.Name)"
                }
                $updatedCount++
            }
            else {
                Write-Info "Unchanged: $($commandFile.Name)"
                $unchangedCount++
            }
        }
        else {
            if (-not $DryRun) {
                Copy-Item -Path $commandFile.FullName -Destination $destFile
                Write-Success "Installed $($commandFile.Name)"
            }
            else {
                Write-Info "[DRY RUN] Would install $($commandFile.Name)"
            }
            $installedCount++
        }
    }

    Write-Host ""
    Write-Info "Commands installation summary for ${ScopeName}:"
    Write-Host "  - Installed: $installedCount new command(s)"
    Write-Host "  - Updated:   $updatedCount command(s)"
    Write-Host "  - Unchanged: $unchangedCount command(s)"
}

function Install-Commands {
    Write-Section "Phase 4b: Inscribing Slash Commands (Scope: $Scope)"

    if (-not (Test-Path $SourceCommandsDir)) {
        Write-Warn "Source commands directory not found: $SourceCommandsDir"
        Write-Warn "Skipping commands installation"
        return
    }

    switch ($Scope) {
        'global' {
            Install-CommandsToDirectory -TargetDir $GlobalCommandsDir -ScopeName "global"
            Write-Success "Global commands setup complete"
        }
        'project' {
            Install-CommandsToDirectory -TargetDir $ProjectCommandsDir -ScopeName "project"
            Write-Success "Project commands setup complete"
        }
        'both' {
            Write-Info "Inscribing to both global and project scopes..."
            Write-Host ""
            Write-Info "=== Inscribing commands to GLOBAL scope ==="
            Install-CommandsToDirectory -TargetDir $GlobalCommandsDir -ScopeName "global"
            Write-Host ""
            Write-Info "=== Inscribing commands to PROJECT scope ==="
            Install-CommandsToDirectory -TargetDir $ProjectCommandsDir -ScopeName "project"
            Write-Host ""
            Write-Success "Commands setup complete for both scopes"
        }
    }
}

# ============================================================================
# PHASE 5: PROJECT STRUCTURE
# ============================================================================

function Install-ProjectStructure {
    Write-Section "Phase 5: Manifesting Project Structure"

    $directories = @(
        (Join-Path $HauntDir "plans"),
        (Join-Path $HauntDir "progress"),
        (Join-Path $HauntDir "completed"),
        (Join-Path $HauntDir "tests"),
        (Join-Path $HauntDir "tests\patterns"),
        (Join-Path $HauntDir "tests\behavior"),
        (Join-Path $HauntDir "tests\e2e"),
        (Join-Path $HauntDir "docs"),
        (Join-Path $HauntDir "docs\research"),
        (Join-Path $HauntDir "docs\validation"),
        (Join-Path $HauntDir "checklists")
    )

    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            if (-not $DryRun) {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
                Write-Success "Created $dir"
            }
            else {
                Write-Info "[DRY RUN] Would create $dir"
            }
        }
        else {
            Write-Info "Exists: $dir"
        }
    }

    # Create initial roadmap if it doesn't exist
    $roadmapFile = Join-Path $HauntDir "plans\roadmap.md"
    if (-not (Test-Path $roadmapFile)) {
        $roadmapContent = @"
# Project Roadmap

## Current Focus: Initial Setup

**Goal:** Set up project infrastructure

**Active Work:**
(No active requirements)

**Recently Completed:**
(None yet)

---

## Backlog

(Add requirements here using the format from gco-roadmap-format rule)
"@

        if (-not $DryRun) {
            Set-Content -Path $roadmapFile -Value $roadmapContent
            Write-Success "Created initial roadmap.md"
        }
        else {
            Write-Info "[DRY RUN] Would create initial roadmap.md"
        }
    }
    else {
        Write-Info "Exists: roadmap.md"
    }
}

# ============================================================================
# PHASE 6: VERIFICATION
# ============================================================================

function Test-Installation {
    Write-Section "Phase 6: Verification"

    $issues = @()

    # Check agents
    $agentsDir = if ($Scope -eq 'global') { $GlobalAgentsDir } else { $ProjectAgentsDir }
    if (Test-Path $agentsDir) {
        $agentCount = (Get-ChildItem -Path $agentsDir -Filter "*.md" -ErrorAction SilentlyContinue).Count
        if ($agentCount -gt 0) {
            Write-Success "Agents: $agentCount found in $agentsDir"
        }
        else {
            $issues += "No agents found in $agentsDir"
            Write-Warn "Agents: None found in $agentsDir"
        }
    }
    else {
        $issues += "Agents directory missing: $agentsDir"
        Write-Warn "Agents: Directory missing - $agentsDir"
    }

    # Check skills
    $skillsDir = if ($Scope -eq 'global') { $GlobalSkillsDir } else { $ProjectSkillsDir }
    if (Test-Path $skillsDir) {
        $skillCount = (Get-ChildItem -Path $skillsDir -Directory -Filter "gco-*" -ErrorAction SilentlyContinue).Count
        if ($skillCount -gt 0) {
            Write-Success "Skills: $skillCount found in $skillsDir"
        }
        else {
            $issues += "No skills found in $skillsDir"
            Write-Warn "Skills: None found in $skillsDir"
        }
    }
    else {
        $issues += "Skills directory missing: $skillsDir"
        Write-Warn "Skills: Directory missing - $skillsDir"
    }

    # Check .haunt directory
    if (Test-Path $HauntDir) {
        Write-Success ".haunt directory exists"
    }
    else {
        $issues += ".haunt directory missing"
        Write-Warn ".haunt: Directory missing"
    }

    # Check Claude CLI
    $claude = Get-Command claude -ErrorAction SilentlyContinue
    if ($claude) {
        Write-Success "Claude Code CLI available"
    }
    else {
        $issues += "Claude Code CLI not found"
        Write-Warn "Claude Code CLI: Not found"
    }

    Write-Host ""

    if ($issues.Count -gt 0) {
        Write-Warn "Verification found $($issues.Count) issue(s):"
        foreach ($issue in $issues) {
            Write-Host "  - $issue"
        }

        if ($Fix) {
            Write-Host ""
            Write-Info "Attempting to fix issues..."
            # Re-run installation
            if (-not $AgentsOnly -and -not $SkillsOnly) {
                Install-Agents
                Install-Skills
                Install-Rules
                Install-ProjectStructure
            }
            elseif ($AgentsOnly) {
                Install-Agents
            }
            elseif ($SkillsOnly) {
                Install-Skills
            }
            Write-Success "Fix attempt completed. Run -Verify again to check."
        }

        return $false
    }

    Write-Success "All verification checks passed!"
    return $true
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

function Main {
    # Show help if requested
    if ($Help) {
        Show-Help
        exit 0
    }

    # Validate parameter combinations
    if ($AgentsOnly -and $SkillsOnly) {
        Write-Err "Cannot use -AgentsOnly and -SkillsOnly together"
        exit 2
    }

    # Show banner
    Show-Banner

    if ($DryRun) {
        Write-Warn "DRY RUN MODE - No changes will be made"
        Write-Host ""
    }

    # Initialize resources (clone if needed)
    Initialize-Resources

    # Verify-only mode
    if ($Verify) {
        $result = Test-Installation
        Remove-ClonedRepo
        if ($result) { exit 0 } else { exit 4 }
    }

    # Check prerequisites
    Test-Prerequisites

    # Run installation phases
    if ($AgentsOnly) {
        Install-Agents
    }
    elseif ($SkillsOnly) {
        Install-Skills
    }
    else {
        Install-Agents
        Install-Skills
        Install-Rules
        Install-Commands
        Install-ProjectStructure
    }

    # Final verification
    Write-Host ""
    Test-Installation | Out-Null

    # Cleanup if remote
    Remove-ClonedRepo

    # Summary
    Write-Section "Setup Complete!"

    Write-Host "Next steps:" -ForegroundColor Green
    Write-Host "  1. Start a dev session:  claude -a dev"
    Write-Host "  2. List available agents: claude --list-agents"
    Write-Host "  3. Check the roadmap:     Get-Content .haunt\plans\roadmap.md"
    Write-Host ""
    Write-Host "Happy haunting!" -ForegroundColor Magenta
}

# Run main
Main
