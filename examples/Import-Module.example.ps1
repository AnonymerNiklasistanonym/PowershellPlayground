#!/usr/bin/env pwsh

# -Force will reload the module in case you made changes
# -Verbose will print what is imported
Import-Module "$PSScriptRoot\..\Helper" -Force -Verbose

Get-Module Helper
