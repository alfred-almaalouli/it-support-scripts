setup() { SCRIPT="$BATS_TEST_DIRNAME/../../bash/system_info.sh"; }

@test "prints all fields in text mode" {
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  for field in Hostname OS Kernel "Uptime" CPUs "Memory total" "Disk / used" "IP address"; do
    [[ "$output" == *"$field"* ]]
  done
}

@test "--json prints valid JSON with the hostname" {
  run bash "$SCRIPT" --json
  [ "$status" -eq 0 ]
  echo "$output" | python3 -c 'import json,sys; d=json.load(sys.stdin); assert d["hostname"]; assert d["cpus"] >= 1'
}

@test "unknown option exits with 2" {
  run bash "$SCRIPT" --wrong
  [ "$status" -eq 2 ]
}
