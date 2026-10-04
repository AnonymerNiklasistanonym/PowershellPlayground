#!/usr/bin/env pwsh

Import-Module "$PSScriptRoot\..\Helper" -Force

Invoke-CommandSummary {Write-Output "Test" && sleep 1s}
#Invoke-CommandSummary {echo "Test" && sleep 60s}
Invoke-CommandSummary {Write-Output "Test" && sleep 1s} -ShowOutput
Invoke-CommandSummary {sleep 1s && date && false} -AllowedToFail
Invoke-CommandSummary {sleep 1s && date && false} -AllowedToFail -RerunOnFailWithOutput
Invoke-CommandSummary {Write-Output "Test" && sleep 1s && false} -AllowedToFail
Invoke-CommandSummary {Write-Output install && npm run format} -ForceColor -ForceUTF8 -WorkingDirectory (Join-Path $PSScriptRoot 'example_nodejs_project') -ShowOutputFilter {
    param(
        [Parameter(Mandatory)]
        $Output
    )
    $waitForOxlintErrorEnd = $false
    $valuesOxlintErrorStart = @("⚠")
    foreach ($line in $Output) {
        if ($line -is [System.Management.Automation.ErrorRecord] -and -not $line.ToString() -match "npm notice run") {
            $line
        } elseif ($line.ToString() -in $valuesOxlintErrorStart) {
            $waitForOxlintErrorEnd = $true
            $line
        } elseif ($waitForOxlintErrorEnd) {
            if ($line.ToString() -match "╰────") {
                $waitForOxlintErrorEnd = $false
            }
            $line
        }
    }
}
Invoke-CommandSummary {npm install && npm test} -ForceColor -ForceUTF8 -WorkingDirectory (Join-Path $PSScriptRoot 'example_nodejs_project')
Invoke-CommandSummary {Write-Output "Test" && sleep 60s}
