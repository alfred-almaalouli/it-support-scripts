setup() {
  SCRIPT="$BATS_TEST_DIRNAME/../../bash/cleanup_temp.sh"
  TMP=$(mktemp -d)
  echo old > "$TMP/old.log";   touch -d "10 days ago" "$TMP/old.log"
  echo new > "$TMP/new.log"
}

teardown() { rm -rf "$TMP"; }

@test "dry run lists old files and deletes nothing" {
  run bash "$SCRIPT" -d "$TMP" -a 7
  [ "$status" -eq 0 ]
  [[ "$output" == *"would delete: $TMP/old.log"* ]]
  [[ "$output" != *"new.log"* ]]
  [ -f "$TMP/old.log" ]
}

@test "--apply deletes only files older than the limit" {
  run bash "$SCRIPT" -d "$TMP" -a 7 --apply
  [ "$status" -eq 0 ]
  [[ "$output" == *"Deleted 1 file(s)"* ]]
  [ ! -f "$TMP/old.log" ]
  [ -f "$TMP/new.log" ]
}

@test "missing folder exits with 2" {
  run bash "$SCRIPT" -d "$TMP/nope"
  [ "$status" -eq 2 ]
}

@test "refuses to clean a system folder" {
  run bash "$SCRIPT" -d /etc
  [ "$status" -eq 2 ]
  [[ "$output" == *"Refusing"* ]]
}

@test "empty folder reports zero files" {
  rm -f "$TMP"/*
  run bash "$SCRIPT" -d "$TMP"
  [ "$status" -eq 0 ]
  [[ "$output" == *"0 file(s)"* ]]
}
