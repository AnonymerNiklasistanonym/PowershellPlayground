#!/usr/bin/env pwsh

enum LogSeverity {
    Debug
    Info
    Warning
    Error
}

function Write-Log {
    param (
        [string]$Message,
        [LogSeverity]$Level = [LogSeverity]::Info,
        [string]$Scope,
        [string]$LogFile,
        [LogSeverity]$LogLevel = [LogSeverity]::Info
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    if ($Scope) {
        $logEntry = "[$Timestamp] [$Level] <$Scope> $Message"
    } else {
        $logEntry = "[$Timestamp] [$Level] $Message"
    }

    if ($Level -ge $LogLevel -and $LogFile) {
        Add-Content -Path $LogFile -Value $logEntry -Encoding UTF8
    }
}
