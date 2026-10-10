BeforeAll {
    $script = Join-Path $PSScriptRoot '..\..\powershell\Clear-TempFiles.ps1'
}

Describe 'Clear-TempFiles' {
    BeforeEach {
        $dir = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $dir | Out-Null
        $old = New-Item -ItemType File -Path (Join-Path $dir 'old.log') -Value 'old'
        $old.LastWriteTime = (Get-Date).AddDays(-10)
        New-Item -ItemType File -Path (Join-Path $dir 'new.log') -Value 'new' | Out-Null
    }

    AfterEach {
        Remove-Item -LiteralPath $dir -Recurse -Force -ErrorAction SilentlyContinue
    }

    It '-WhatIf finds old files but deletes nothing' {
        $result = & $script -Path $dir -OlderThanDays 7 -WhatIf
        $result.Found | Should -Be 1
        $result.Deleted | Should -Be 0
        Join-Path $dir 'old.log' | Should -Exist
    }

    It 'deletes only files older than the limit' {
        $result = & $script -Path $dir -OlderThanDays 7 -Confirm:$false
        $result.Deleted | Should -Be 1
        Join-Path $dir 'old.log' | Should -Not -Exist
        Join-Path $dir 'new.log' | Should -Exist
    }

    It 'throws for a folder that does not exist' {
        { & $script -Path (Join-Path $dir 'nope') } | Should -Throw '*not found*'
    }

    It 'refuses to clean a drive root' {
        $root = [System.IO.Path]::GetPathRoot($dir)
        { & $script -Path $root -WhatIf } | Should -Throw '*Refusing*'
    }
}
