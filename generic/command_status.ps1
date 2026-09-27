#!/usr/bin/env pwsh

function Format-Duration {
    param(
        [TimeSpan] $Duration
    )
    if ($Duration.TotalMinutes -lt 1) {
        return "{0:N2}s" -f $Duration.TotalSeconds
    }
    if ($Duration.TotalHours -lt 1) {
        return "{0:N2}m" -f $Duration.TotalMinutes
    }
    return "{0:N2}h" -f $Duration.TotalHours
}

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

.PARAMETER RerunOnFailWithOutput
    Instead of showing the recorded output rerun the command (e.g. for outputs that use colors and break when recorded).

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
        [switch] $RerunOnFailWithOutput
    )
    $relativePath = [System.IO.Path]::GetRelativePath(
        (Get-Location).Path,
        $WorkingDirectory
    )
    $display = if ($relativePath -eq '.') {
        "$Command"
    } else {
        "$Command [$relativePath]"
    }
    $status = "[..]  $display"

    Write-Host $status -NoNewline

    if (-not (Test-Path $WorkingDirectory -PathType Container)) {
        Write-Host ""
        $absolutePath = [System.IO.Path]::GetFullPath($WorkingDirectory)
        throw "Directory does not exist: $WorkingDirectory [$absolutePath]"
    }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    Push-Location $WorkingDirectory -ErrorAction Stop
    try {
        $output = & $Command 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }
    $sw.Stop()

    Write-Host "`r$status`r" -NoNewline
    $duration = Format-Duration $sw.Elapsed
    if ($exitCode -eq 0) {
        Write-Host "[OK]  $display ($duration)" -ForegroundColor Green
        if ($ShowOutput) {
            $output
        }
    } else {
        $color = [ConsoleColor]::Red
        if ($AllowedToFail) {
            $color = [ConsoleColor]::Yellow
        }
        Write-Host "[ERR] $display (exit code $exitCode, $duration)" -ForegroundColor $color
        if (-not $AllowedToFail) {
            exit 1
        }
        if ($RerunOnFailWithOutput) {
            Push-Location $WorkingDirectory -ErrorAction Stop
            try {
                & $Command
            }
            finally {
                Pop-Location
            }
        } elseif ($output) {
            $output
        }
        if (-not $AllowedToFail) {
            exit 1
        }
    }
}
