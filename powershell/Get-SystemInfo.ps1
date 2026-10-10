<#
.SYNOPSIS
    Collects basic system information for a support ticket.
.EXAMPLE
    .\Get-SystemInfo.ps1 | Format-List
#>
[CmdletBinding()]
param()

$os   = Get-CimInstance -ClassName Win32_OperatingSystem
$cs   = Get-CimInstance -ClassName Win32_ComputerSystem
$disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"

[PSCustomObject]@{
    ComputerName     = $env:COMPUTERNAME
    UserName         = $env:USERNAME
    OS               = $os.Caption
    Version          = $os.Version
    UptimeHours      = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalHours, 1)
    CPUs             = $cs.NumberOfLogicalProcessors
    MemoryTotalGB    = [math]::Round($cs.TotalPhysicalMemory / 1GB, 1)
    MemoryFreeGB     = [math]::Round(($os.FreePhysicalMemory * 1KB) / 1GB, 1)
    DiskCFreeGB      = [math]::Round($disk.FreeSpace / 1GB, 1)
    DiskCUsedPercent = [math]::Round(100 - ($disk.FreeSpace / $disk.Size * 100), 1)
}
