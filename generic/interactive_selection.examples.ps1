#!/usr/bin/env pwsh

. "$PSScriptRoot/interactive_selection.ps1"

# Get help
Get-Help Select-ListItem -Full

# Select a git branch
$branch = git branch --format='%(refname:short)' | Select-ListItem -Prompt 'Select a branch to switch to' -HighlightPattern (git branch --show-current) -DisplayScript {
    param(
        [Parameter(Mandatory)]
        $Branch
    )
    git branch --format="%(HEAD) %(refname:short) [last changed %(committerdate:relative)] (%(committerdate:format:%Y-%m-%d %H:%M))" --list $Branch
}
if ($null -ne $branch) {
    Write-Host "Switch to branch: $branch"
    #git switch $branch
} else {
    Write-Host "No branch selected"
}
