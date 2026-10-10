<#
.SYNOPSIS
    Checks DNS resolution and TCP reachability of one or more host:port targets.
.EXAMPLE
    .\Test-Endpoint.ps1 -Target 'github.com:443', 'outlook.office365.com:443'
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string[]]$Target,

    [ValidateRange(100, 60000)]
    [int]$TimeoutMs = 3000
)

foreach ($item in $Target) {
    if ($item -notmatch '^(?<name>[^:]+):(?<port>\d{1,5})$') {
        throw "Invalid target '$item' (expected host:port)"
    }
    $name = $Matches.name
    $port = [int]$Matches.port

    $dnsOk = $true
    try { [void][System.Net.Dns]::GetHostAddresses($name) } catch { $dnsOk = $false }

    $tcpOk = $false
    $timeMs = $null
    if ($dnsOk) {
        $client = [System.Net.Sockets.TcpClient]::new()
        $watch = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            $connect = $client.ConnectAsync($name, $port)
            if ($connect.Wait($TimeoutMs) -and $client.Connected) {
                $tcpOk = $true
                $timeMs = $watch.ElapsedMilliseconds
            }
        }
        catch {
            $tcpOk = $false
        }
        finally {
            $client.Dispose()
        }
    }

    [PSCustomObject]@{
        Target = $item
        Dns    = $dnsOk
        Tcp    = $tcpOk
        TimeMs = $timeMs
    }
}
