#!/usr/bin/env bash
# Finds (and optionally deletes) files older than N days in a folder.
# Dry run by default, nothing is deleted without --apply.
# Usage: cleanup_temp.sh -d <dir> [-a <days>] [--apply]
set -euo pipefail

dir=""
age=7
apply=false
while [[ $# -gt 0 ]]; do
  case $1 in
    -d) dir=$2; shift 2 ;;
    -a) age=$2; shift 2 ;;
    --apply) apply=true; shift ;;
    *) echo "Usage: $(basename "$0") -d <dir> [-a <days>] [--apply]" >&2; exit 2 ;;
  esac
done

if [[ -z "$dir" || ! -d "$dir" ]]; then
  echo "Folder not found: '${dir}'" >&2
  exit 2
fi
if [[ ! "$age" =~ ^[0-9]+$ ]]; then
  echo "Age must be a whole number of days" >&2
  exit 2
fi
case "$(cd "$dir" && pwd)" in
  /|/bin|/boot|/etc|/home|/lib|/usr|/var) echo "Refusing to clean system folder '$dir'" >&2; exit 2 ;;
esac

mapfile -d '' files < <(find "$dir" -type f -mtime +"$age" -print0)
total=0
for f in "${files[@]}"; do
  total=$(( total + $(stat -c %s "$f") ))
done

if $apply; then
  for f in "${files[@]}"; do rm -f -- "$f"; done
  echo "Deleted ${#files[@]} file(s), freed $(( total / 1024 )) KB"
else
  for f in "${files[@]}"; do echo "would delete: $f"; done
  echo "Dry run: ${#files[@]} file(s), $(( total / 1024 )) KB. Use --apply to delete."
fi
