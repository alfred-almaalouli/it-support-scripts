<#
.SYNOPSIS
    Deletes files older than a number of days from a folder.
.DESCRIPTION
    Supports -WhatIf, so you can see what would be deleted first.
    Drive roots, the Windows folder, Program Files and the user profile root are protected.
.EXAMPLE
    .\Clear-TempFiles.ps1 -Path $env:TEMP -OlderThanDays 14 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$Path,

    [ValidateRange(0, 3650)]
    [int]$OlderThanDays = 7
)

if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
    throw "Folder not found: '$Path'"
}

$fullPath = (Resolve-Path -LiteralPath $Path).ProviderPath.TrimEnd('\', '/')
$protected = @(
    $env:SystemRoot
    $env:ProgramFiles
    ${env:ProgramFiles(x86)}
    $env:USERPROFILE
    [System.IO.Path]::GetPathRoot($fullPath)
) | Where-Object { $_ } | ForEach-Object { $_.TrimEnd('\', '/') }

if ($protected -contains $fullPath -or $fullPath -eq '') {
    throw "Refusing to clean protected folder '$Path'"
}

$limit = (Get-Date).AddDays(-$OlderThanDays)
$files = @(Get-ChildItem -LiteralPath $fullPath -File -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -lt $limit })

$deleted = 0
$bytes = 0
foreach ($file in $files) {
    if ($PSCmdlet.ShouldProcess($file.FullName, 'Delete')) {
        Remove-Item -LiteralPath $file.FullName -Force
        $deleted++
        $bytes += $file.Length
    }
}

[PSCustomObject]@{
    Found   = $files.Count
    Deleted = $deleted
    FreedKB = [math]::Round($bytes / 1KB, 1)
}
