setup() {
  SCRIPT="$BATS_TEST_DIRNAME/../../bash/network_check.sh"
  PORT=$(python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1]); s.close()')
  python3 -m http.server "$PORT" --bind 127.0.0.1 >/dev/null 2>&1 &
  SERVER_PID=$!
  for _ in $(seq 1 50); do (exec 3<>/dev/tcp/127.0.0.1/$PORT) 2>/dev/null && break; sleep 0.1; done
}

teardown() { kill "$SERVER_PID" 2>/dev/null || true; }

@test "reachable local port is reported as OK" {
  run bash "$SCRIPT" "localhost:$PORT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"localhost:$PORT"*"OK"*"OK"* ]]
}

@test "closed port fails with exit code 1" {
  run bash "$SCRIPT" -t 1 "localhost:1"
  [ "$status" -eq 1 ]
  [[ "$output" == *"not reachable"* ]]
}

@test "unknown host fails DNS" {
  run bash "$SCRIPT" -t 1 "does-not-exist.invalid:80"
  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL"* ]]
}

@test "target without port is rejected with exit code 2" {
  run bash "$SCRIPT" "localhost"
  [ "$status" -eq 2 ]
}
