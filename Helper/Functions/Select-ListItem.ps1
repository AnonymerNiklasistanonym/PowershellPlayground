#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Select an item from an indexed list.

.PARAMETER DisplayScript
    A script that is run for the current item to generate a custom display string.

    git branch --format='%(refname:short)' | Select-ListItem -DisplayScript {
        param(
            [Parameter(Mandatory)]
            $Branch
        )
        git branch --format="%(HEAD) %(refname:short) %(committerdate:relative)" --list $Branch
    }

.PARAMETER HighlightPattern
    A regex with which items that match are highlighted from the others.

    git branch --format='%(refname:short)' | Select-ListItem -HighlightPattern (git branch --show-current)

.PARAMETER HighlightColor
    The color used for highlighted items.

.PARAMETER Prompt
    The prompt shown to the user.

.EXAMPLE
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

    Switch to a specific git branch.
#>
function Select-ListItem {
    param(
        [Parameter(ValueFromPipeline = $true)]
        $InputObject,
        [scriptblock]$DisplayScript,
        [ConsoleColor]$HighlightColor = [ConsoleColor]::Yellow,
        [string]$HighlightPattern,
        [string]$Prompt = "Select an item"
    )

    begin {
        $items = @()
    }

    process {
        $items += $InputObject
    }

    end {
        if ($items.Count -eq 0) {
            return
        }

        for ($i = 0; $i -lt $items.Count; $i++) {
            if ($DisplayScript) {
                $display = & $DisplayScript $items[$i]
            }
            else {
                $display = $items[$i]
            }
            $item = "[$i] $display"
            if ($HighlightPattern -and $items[$i] -match $HighlightPattern) {
                Write-Host $item -ForegroundColor $HighlightColor
            }
            else {
                Write-Host $item
            }
        }

        $selection = Read-Host $Prompt
        $index = 0
        if ([int]::TryParse($selection, [ref]$index) -and
            $index -ge 0 -and
            $index -lt $items.Count) {
            return $items[$index]
        }
    }
}
