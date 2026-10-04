#!/usr/bin/env pwsh

function Set-IOEncoding {
    param(
        [System.Text.Encoding]$InputEncoding = [System.Text.UTF8Encoding]::new($false),
        [System.Text.Encoding]$OutputEncoding = [System.Text.UTF8Encoding]::new($false),
        [switch]$Verbose
    )
    $previousIOEncoding = [pscustomobject]@{
        InputEncoding  = [Console]::InputEncoding
        OutputEncoding = [Console]::OutputEncoding
    }
    if ([Console]::InputEncoding.CodePage -ne $InputEncoding.CodePage) {
        if ($Verbose) {
            Write-Warning "Set OutputEncoding from $([Console]::InputEncoding.BodyName) to $($InputEncoding.BodyName)"
        }
        [Console]::InputEncoding = $InputEncoding
    }
    if ([Console]::OutputEncoding.CodePage -ne $OutputEncoding.CodePage) {
        if ($Verbose) {
            Write-Warning "Set OutputEncoding from $([Console]::OutputEncoding.BodyName) to $($OutputEncoding.BodyName)"
        }
        [Console]::OutputEncoding = $OutputEncoding
    }
    return $previousIOEncoding
}
