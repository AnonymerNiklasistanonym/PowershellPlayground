#!/usr/bin/env pwsh

Import-Module "$PSScriptRoot\..\Helper" -Force

$logFile = "example.log"

Invoke-CommandSummary {Write-Output "Test" && sleep 1s}
#Invoke-CommandSummary {echo "Test" && sleep 60s}
Invoke-CommandSummary {Write-Output "Test" && sleep 1s} -ShowOutput
Invoke-CommandSummary {Write-Output "Test" && sleep 1s} -ShowOutput -LogFile $logFile
Invoke-CommandSummary {sleep 1s && date && false} -AllowedToFail -LogFile $logFile
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
} -LogFile $logFile
Invoke-CommandSummary {npm install && npm test} -ForceColor -ForceUTF8 -WorkingDirectory (Join-Path $PSScriptRoot 'example_nodejs_project') -LogFile $logFile
Invoke-CommandSummary {Write-Output "Test" && sleep 60s}
