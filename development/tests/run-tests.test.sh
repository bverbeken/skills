#!/usr/bin/env bash
set -u

script="$(cd "$(dirname "$0")/../skills/implement" && pwd)/run-tests"
failures=0

make_tools_dir() {
  local dir="$1"
  mkdir -p "$dir"
  for tool in /usr/bin/* /bin/*; do
    local name
    name="$(basename "$tool")"
    case "$name" in timeout | gtimeout) continue ;; esac
    [ -e "$dir/$name" ] || ln -s "$tool" "$dir/$name"
  done
}

passing_timeout_stub() {
  cat > "$1" <<'STUB'
#!/usr/bin/env bash
echo "$@" > "$(dirname "$0")/timeout-args"
shift 3
exec "$@"
STUB
  chmod +x "$1"
}

setup() {
  work="$(mktemp -d)"
  stubs="$work/stubs"
  mkdir -p "$stubs"
  make_tools_dir "$work/tools"
  test_path="$stubs:$work/tools"
}

run() {
  output="$(PATH="$test_path" TMPDIR="$work" "$script" "$@" 2>&1)"
  status=$?
}

expect_contains() {
  if [[ "$output" != *"$1"* ]]; then
    echo "  expected output to contain: $1"
    failed=1
  fi
}

expect_not_contains() {
  if [[ "$output" == *"$1"* ]]; then
    echo "  expected output not to contain: $1"
    failed=1
  fi
}

expect_equal() {
  if [ "$1" != "$2" ]; then
    echo "  expected '$2', got '$1'"
    failed=1
  fi
}

expect_line() {
  if ! grep -qxF -- "$1" <<< "$output"; then
    echo "  expected a line: $1"
    failed=1
  fi
}

expect_no_line() {
  if grep -qxF -- "$1" <<< "$output"; then
    echo "  expected no line: $1"
    failed=1
  fi
}

log_path() {
  sed -n 's/^Log: //p' <<< "$output"
}

test_a_passing_run_prints_the_exit_code_the_log_and_the_last_5_lines() {
  passing_timeout_stub "$stubs/timeout"
  run 10m bash -c 'for i in $(seq 1 20); do echo "line $i"; done'
  expect_equal "$status" 0
  expect_contains "Exit code: 0"
  expect_contains "$(printf 'line 16\nline 17\nline 18\nline 19\nline 20')"
  expect_not_contains "line 15"
  expect_equal "$(cat "$(log_path)" | wc -l | tr -d ' ')" 20
  expect_equal "$(cat "$stubs/timeout-args")" "-k 1m 10m bash -c for i in \$(seq 1 20); do echo \"line \$i\"; done"
}

test_a_failing_run_prints_the_failures_with_context_and_the_last_15_lines() {
  passing_timeout_stub "$stubs/timeout"
  cat > "$work/suite" <<'SUITE'
for i in $(seq 1 100); do
  case $i in
    20) echo "test_a FAILED" ;;
    40) echo "Error in b" ;;
    60) echo "✕ c" ;;
    70) echo "✗ d" ;;
    *) echo "line $i" ;;
  esac
done
exit 3
SUITE
  run 10m bash "$work/suite"
  expect_equal "$status" 3
  expect_contains "Exit code: 3"
  expect_line "test_a FAILED"
  expect_line "Error in b"
  expect_line "✕ c"
  expect_line "✗ d"
  expect_line "line 15"
  expect_line "line 25"
  expect_line "line 35"
  expect_line "line 55"
  expect_line "line 75"
  expect_line "line 86"
  expect_line "line 100"
  expect_no_line "line 14"
  expect_no_line "line 26"
  expect_no_line "line 50"
  expect_no_line "line 80"
}

for test in $(declare -F | awk '{print $3}' | grep '^test_'); do
  failed=0
  setup
  "$test"
  rm -rf "$work"
  if [ "$failed" = 1 ]; then
    echo "FAIL $test"
    failures=$((failures + 1))
  else
    echo "ok   $test"
  fi
done

echo "$failures failed"
[ "$failures" = 0 ]
