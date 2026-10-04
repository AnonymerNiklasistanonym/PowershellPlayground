BeforeAll {
    . $PSScriptRoot/../Functions/Format-ElapsedTime.ps1
}

Describe 'Format-ElapsedTime' {
    It 'formats milliseconds' {
        Format-ElapsedTime ([TimeSpan]::FromMilliseconds(420)) |
        Should -Be '420ms'
    }

    It 'formats seconds' {
        Format-ElapsedTime ([TimeSpan]::FromSeconds(12.3)) |
        Should -Be '12s'
    }

    It 'formats minutes and seconds' {
        Format-ElapsedTime ([TimeSpan]::FromSeconds(83)) |
        Should -Be '1m 23s'
    }

    It 'formats hours, minutes' {
        Format-ElapsedTime ([TimeSpan]::FromSeconds(3723)) |
        Should -Be '1h 2m'
    }

    It 'formats days, hours and minutes' {
        Format-ElapsedTime ([TimeSpan]::FromMinutes(3005)) |
        Should -Be '2d 2h 5m'
    }
}