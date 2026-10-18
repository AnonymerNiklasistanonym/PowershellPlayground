#!/usr/bin/env pwsh

. $PSScriptRoot/Format-ElapsedTime.ps1
. $PSScriptRoot/Set-IOEncoding.ps1
. $PSScriptRoot/Write-Log.ps1

<#
.SYNOPSIS
    Invoke a command and return a summary of its execution (e.g. OK/green if exit code is 0, otherwise ERR/red).

.PARAMETER Command
    A script block containing the commands to be executed.

.PARAMETER WorkingDirectory
    The directory in which the commands should be executed.

.PARAMETER AllowedToFail
    Do not exit the script if the commands have a bad exit code.

.PARAMETER ShowOutput
    Show the output even if the exit code was OK.

.PARAMETER ShowOutputFilter
    Customize showing output even if the exit code was OK (-ShowOutput takes precedence).

.PARAMETER ForceColor
    Add environment variables that force colors to combat pipe detection that turns colors off.

.PARAMETER ForceUTF8
    Temporarily set the input and output encoding to UTF-8 if its something else.

.PARAMETER RerunOnFailWithOutput
    Instead of showing the recorded output rerun the command (e.g. for outputs that use colors and break when recorded).

.PARAMETER LogFile
    Store/Append important logs to a file

.PARAMETER LogLevel
    Store/Append important logs to a file

.EXAMPLE
    Invoke-CommandSummary {echo "Test" && sleep 1s}
    Invoke-CommandSummary {echo "Test" && sleep 60s}
    Invoke-CommandSummary {echo "Test" && sleep 1s} -ShowOutput
    Invoke-CommandSummary {sleep 1s && date && false} -AllowedToFail
    Invoke-CommandSummary {sleep 1s && date && false} -AllowedToFail -RerunOnFailWithOutput
    Invoke-CommandSummary {sleep 1s && date && false}

    Invoke commands with multiple options.
#>
function Invoke-CommandSummary {
    param(
        [Parameter(Mandatory)]
        [scriptblock] $Command,
        [string] $WorkingDirectory = (Get-Location),
        [switch] $AllowedToFail,
        [switch] $ShowOutput,
        [scriptblock] $ShowOutputFilter,
        [switch] $ForceColor,
        [switch] $ForceUTF8,
        [switch] $RerunOnFailWithOutput,
        [string] $LogFile,
        [ValidateSet("Debug", "Error", "Warning", "Info")]
        [string] $LogLevel = "Info"
    )
    $displayPath = if ($PSVersionTable.PSVersion.Major -ge 7) {
        [System.IO.Path]::GetRelativePath(
            (Get-Location).Path,
            $WorkingDirectory
        )
    }
    else {
        $WorkingDirectory
    }
    $display = if ($displayPath -eq '.') {
        "$Command"
    }
    else {
        "$Command [$displayPath]"
    }
    $status = "[..]  $display"

    Write-Host $status -NoNewline
    Write-Log $display -Level Info -Scope "Invoke-CommandSummary:Command" -LogFile $LogFile -LogLevel $LogLevel

    if (-not (Test-Path $WorkingDirectory -PathType Container)) {
        Write-Host ""
        $absolutePath = [System.IO.Path]::GetFullPath($WorkingDirectory)
        throw "Directory does not exist: $WorkingDirectory [$absolutePath]"
    }

    try {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        Push-Location $WorkingDirectory -ErrorAction Stop
        $oldErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        if ($ForceColor) {
            $env:FORCE_COLOR = "1"
        }
        if ($ForceUTF8) {
            $previousIOEncoding = Set-IOEncoding
        }
        $output = & $Command 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $oldErrorActionPreference
        if ($ForceColor) {
            Remove-Item Env:FORCE_COLOR
        }
        Pop-Location
        $sw.Stop()
    }

    Write-Host "`r$status`r" -NoNewline

    $duration = Format-ElapsedTime $sw.Elapsed

    if ($exitCode -eq 0) {
        $levelStatus = [LogSeverity]::Info
        $levelOutput = [LogSeverity]::Debug
    }
    elseif ($AllowedToFail) {
        $levelStatus = [LogSeverity]::Warning
        $levelOutput = [LogSeverity]::Warning
    }
    else {
        $levelStatus = [LogSeverity]::Error
        $levelOutput = [LogSeverity]::Error
    }
    Write-Log "Exit code: $exitCode, Allowed to fail: $AllowedToFail, Duration: $duration" -Level $levelStatus -Scope "Invoke-CommandSummary:Status" -LogFile $LogFile -LogLevel $LogLevel
    $PlainTextOutput = ($output -join "`n") -replace '\e\[[0-9;]*m', ''
    Write-Log $PlainTextOutput -Level $levelOutput -Scope "Invoke-CommandSummary:Output" -LogFile $LogFile -LogLevel $LogLevel

    if ($exitCode -eq 0) {
        Write-Host "[OK]  $display ($duration)" -ForegroundColor Green
        if ($ShowOutput) {
            $output
        }
        elseif ($ShowOutputFilter) {
            & $ShowOutputFilter $output
        }
    }
    else {
        $statusTextColor = if ($AllowedToFail) {
            [ConsoleColor]::Yellow
        }
        else {
            [ConsoleColor]::Red
        }
        Write-Host "[ERR] $display (exit code $exitCode, $duration)" -ForegroundColor $statusTextColor
        if ($RerunOnFailWithOutput) {
            Push-Location $WorkingDirectory -ErrorAction Stop
            try {
                $oldErrorActionPreference = $ErrorActionPreference
                $ErrorActionPreference = 'Continue'
                & $Command
            }
            finally {
                $ErrorActionPreference = $oldErrorActionPreference
                Pop-Location
            }
        }
        elseif ($output) {
            $output
        }
    }
    if ($ForceUTF8) {
        Set-IOEncoding -OutputEncoding $previousIOEncoding.OutputEncoding -InputEncoding $previousIOEncoding.InputEncoding | Out-Null
    }
    if (-not $exitCode -eq 0 -and -not $AllowedToFail) {
        Write-Log "Exit because of exit code $exitCode" -Level Error -Scope "Invoke-CommandSummary:Exit" -LogFile $LogFile -LogLevel $LogLevel
        exit 1
    }
}

Export-ModuleMember -Function Invoke-CommandSummary
