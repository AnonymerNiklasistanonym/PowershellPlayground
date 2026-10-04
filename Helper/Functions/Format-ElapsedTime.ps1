#!/usr/bin/env pwsh

function Format-ElapsedTime {
    param(
        [TimeSpan] $Duration
    )
    if ($Duration.TotalSeconds -lt 1) {
        return "{0}ms" -f [math]::Round($Duration.TotalMilliseconds)
    }
    if ($Duration.TotalMinutes -lt 1) {
        return "{0}s" -f [math]::Round($Duration.TotalSeconds)
    }
    if ($Duration.TotalHours -lt 1) {
        return "{0}m {1}s" -f $Duration.Minutes, [math]::Round($Duration.Seconds)
    }
    if ($Duration.TotalDays -lt 1) {
        return "{0}h {1}m" -f $Duration.Hours, $Duration.Minutes
    }
    "{0}d {1}h {2}m" -f $Duration.Days, $Duration.Hours, $Duration.Minutes
}
