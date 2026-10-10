BeforeAll {
    $script = Join-Path $PSScriptRoot '..\..\powershell\Get-SystemInfo.ps1'
}

Describe 'Get-SystemInfo' {
    BeforeAll {
        $info = & $script
    }

    It 'returns the computer name' {
        $info.ComputerName | Should -Be $env:COMPUTERNAME
    }

    It 'reports at least one CPU' {
        $info.CPUs | Should -BeGreaterOrEqual 1
    }

    It 'reports memory and disk values in a valid range' {
        $info.MemoryTotalGB | Should -BeGreaterThan 0
        $info.DiskCUsedPercent | Should -BeGreaterOrEqual 0
        $info.DiskCUsedPercent | Should -BeLessOrEqual 100
    }
}
