#!/usr/bin/env bash
# Checks DNS resolution and TCP reachability for a list of host:port targets.
# Usage: network_check.sh [-t timeout_seconds] host:port [host:port ...]
# Exit code: 0 if all targets are reachable, 1 if at least one fails, 2 on wrong usage.
set -uo pipefail

timeout_s=3
while getopts ":t:" opt; do
  case $opt in
    t) timeout_s=$OPTARG ;;
    *) echo "Usage: $(basename "$0") [-t seconds] host:port ..." >&2; exit 2 ;;
  esac
done
shift $((OPTIND - 1))

if [[ $# -eq 0 ]]; then
  set -- "github.com:443" "google.com:443" "1.1.1.1:53"
fi

failures=0
printf '%-30s %-6s %-6s %s\n' "TARGET" "DNS" "TCP" "TIME_MS"
for target in "$@"; do
  host=${target%:*}
  port=${target##*:}
  if [[ "$host" == "$target" || ! "$port" =~ ^[0-9]+$ ]]; then
    echo "Invalid target '$target' (expected host:port)" >&2
    exit 2
  fi

  dns="OK"
  if ! getent hosts "$host" >/dev/null 2>&1; then
    dns="FAIL"
  fi

  tcp="FAIL"
  ms="-"
  if [[ $dns == "OK" ]]; then
    start=$(date +%s%N)
    if timeout "$timeout_s" bash -c "exec 3<>/dev/tcp/$host/$port" 2>/dev/null; then
      tcp="OK"
      ms=$(( ($(date +%s%N) - start) / 1000000 ))
    fi
  fi

  [[ $tcp == "OK" ]] || failures=$((failures + 1))
  printf '%-30s %-6s %-6s %s\n' "$target" "$dns" "$tcp" "$ms"
done

if [[ $failures -gt 0 ]]; then
  echo "$failures target(s) not reachable" >&2
  exit 1
fi
