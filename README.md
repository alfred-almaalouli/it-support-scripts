# IT Support Scripts

![CI](https://github.com/alfred-almaalouli/it-support-scripts/actions/workflows/ci.yml/badge.svg)

Small scripts for everyday IT support tasks, for **Windows (PowerShell)** and **Linux (Bash)**. Every script is linted and tested automatically in GitHub Actions on a Windows and a Linux runner.

## Scripts

| Task | PowerShell (Windows) | Bash (Linux) |
|------|----------------------|--------------|
| System overview for a ticket (OS, uptime, CPU, RAM, disk, IP) | [`Get-SystemInfo.ps1`](powershell/Get-SystemInfo.ps1) | [`system_info.sh`](bash/system_info.sh) (`--json` for machine-readable output) |
| Check DNS and TCP reachability of servers (e.g. VPN, mail, intranet) | [`Test-Endpoint.ps1`](powershell/Test-Endpoint.ps1) | [`network_check.sh`](bash/network_check.sh) |
| Clean up old temp files safely | [`Clear-TempFiles.ps1`](powershell/Clear-TempFiles.ps1) (`-WhatIf`) | [`cleanup_temp.sh`](bash/cleanup_temp.sh) (dry run by default) |

## Examples

```powershell
.\powershell\Get-SystemInfo.ps1 | Format-List
.\powershell\Test-Endpoint.ps1 -Target 'outlook.office365.com:443', 'github.com:443'
.\powershell\Clear-TempFiles.ps1 -Path $env:TEMP -OlderThanDays 14 -WhatIf
```

```bash
./bash/system_info.sh --json
./bash/network_check.sh -t 2 intranet.local:443 8.8.8.8:53
./bash/cleanup_temp.sh -d /tmp/app-logs -a 14            # dry run
./bash/cleanup_temp.sh -d /tmp/app-logs -a 14 --apply    # delete
```

`network_check.sh` returns exit code 1 when a target is not reachable, so it can be used in monitoring or scheduled tasks.

## Safety

- Cleanup never deletes anything without `--apply` / without dropping `-WhatIf`.
- System folders (drive roots, Windows, Program Files, `/etc`, `/usr`, ...) are refused.

## Tests

| | Lint | Tests |
|---|------|-------|
| Bash | ShellCheck | [bats](tests/bash) (12 tests, incl. a local test server for the network check) |
| PowerShell | PSScriptAnalyzer | [Pester 5](tests/powershell) (12 tests, incl. a local TCP listener) |

```bash
bats tests/bash
```
```powershell
Invoke-Pester -Path tests/powershell -Output Detailed
```

## Author

Alfred Al Maalouli – [GitHub](https://github.com/alfred-almaalouli)
