#!/usr/bin/env bash
# Prints a short system overview for a support ticket.
# Usage: system_info.sh [--json]
set -euo pipefail

json=false
if [[ "${1:-}" == "--json" ]]; then
  json=true
elif [[ -n "${1:-}" ]]; then
  echo "Usage: $(basename "$0") [--json]" >&2
  exit 2
fi

host=$(hostname)
os=$( (grep -m1 '^PRETTY_NAME=' /etc/os-release 2>/dev/null || echo 'PRETTY_NAME=unknown') | cut -d= -f2 | tr -d '"')
kernel=$(uname -r)
uptime_s=$(cut -d. -f1 /proc/uptime 2>/dev/null || echo 0)
uptime_h=$(( uptime_s / 3600 ))
cpus=$(nproc 2>/dev/null || echo 1)
mem_total_mb=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)
mem_free_mb=$(awk '/MemAvailable/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)
disk_used_pct=$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')
ip_addr=$(hostname -I 2>/dev/null | awk '{print $1}')
ip_addr=${ip_addr:-unknown}

if $json; then
  printf '{"hostname":"%s","os":"%s","kernel":"%s","uptime_hours":%d,"cpus":%d,"memory_total_mb":%d,"memory_available_mb":%d,"disk_root_used_percent":%d,"ip":"%s"}\n' \
    "$host" "$os" "$kernel" "$uptime_h" "$cpus" "$mem_total_mb" "$mem_free_mb" "$disk_used_pct" "$ip_addr"
else
  printf '%-22s %s\n' "Hostname:" "$host" "OS:" "$os" "Kernel:" "$kernel" \
    "Uptime (hours):" "$uptime_h" "CPUs:" "$cpus" \
    "Memory total (MB):" "$mem_total_mb" "Memory free (MB):" "$mem_free_mb" \
    "Disk / used (%):" "$disk_used_pct" "IP address:" "$ip_addr"
fi
