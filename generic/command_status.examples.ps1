#!/usr/bin/env pwsh

. "$PSScriptRoot/command_status.ps1"

Invoke-CommandSummary {echo "Test" && sleep 1s}
#Invoke-CommandSummary {echo "Test" && sleep 60s}
Invoke-CommandSummary {echo "Test" && sleep 1s} -ShowOutput
Invoke-CommandSummary {sleep 1s && date && false} -AllowedToFail
Invoke-CommandSummary {sleep 1s && date && false} -AllowedToFail -RerunOnFailWithOutput
Invoke-CommandSummary {echo "Test" && sleep 1s && false} -AllowedToFail
Invoke-CommandSummary {npm install && npm test} -WorkingDirectory (Join-Path $PSScriptRoot 'example')
Invoke-CommandSummary {echo "Test" && sleep 60s}
