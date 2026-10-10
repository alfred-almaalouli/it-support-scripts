BeforeAll {
    $script = Join-Path $PSScriptRoot '..\..\powershell\Test-Endpoint.ps1'
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, 0)
    $listener.Start()
    $port = $listener.LocalEndpoint.Port
}

AfterAll {
    $listener.Stop()
}

Describe 'Test-Endpoint' {
    It 'reports an open local port as reachable' {
        $result = & $script -Target "127.0.0.1:$port"
        $result.Dns | Should -BeTrue
        $result.Tcp | Should -BeTrue
        $result.TimeMs | Should -Not -BeNullOrEmpty
    }

    It 'reports a closed port as not reachable' {
        $result = & $script -Target '127.0.0.1:1' -TimeoutMs 1000
        $result.Tcp | Should -BeFalse
    }

    It 'reports an unknown host as DNS failure' {
        $result = & $script -Target 'does-not-exist.invalid:80' -TimeoutMs 1000
        $result.Dns | Should -BeFalse
        $result.Tcp | Should -BeFalse
    }

    It 'returns one result per target' {
        $result = & $script -Target "127.0.0.1:$port", '127.0.0.1:1' -TimeoutMs 1000
        $result.Count | Should -Be 2
    }

    It 'throws for a target without port' {
        { & $script -Target 'localhost' } | Should -Throw '*expected host:port*'
    }
}
