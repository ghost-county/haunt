#!/bin/bash
# Shared helpers for Haunt eval scenarios.

PASS=0
FAIL=0

check_file() {
    local desc="$1"
    local path="$2"
    if [[ -f "$path" ]]; then
        echo "  ok  $desc"
        PASS=$((PASS + 1))
    else
        echo "  FAIL $desc"
        FAIL=$((FAIL + 1))
    fi
}

check_exec() {
    local desc="$1"
    local path="$2"
    if [[ -x "$path" ]]; then
        echo "  ok  $desc"
        PASS=$((PASS + 1))
    else
        echo "  FAIL $desc"
        FAIL=$((FAIL + 1))
    fi
}

check_syntax() {
    local desc="$1"
    local file="$2"
    if bash -n "$file" 2>/dev/null; then
        echo "  ok  $desc"
        PASS=$((PASS + 1))
    else
        echo "  FAIL $desc (syntax error)"
        FAIL=$((FAIL + 1))
    fi
}

check_exit() {
    local desc="$1"
    local expected="$2"
    local actual="$3"
    if [[ "$actual" -eq "$expected" ]]; then
        echo "  ok  $desc"
        PASS=$((PASS + 1))
    else
        echo "  FAIL $desc (expected exit $expected, got $actual)"
        FAIL=$((FAIL + 1))
    fi
}

check_nonzero_exit() {
    local desc="$1"
    local actual="$2"
    if [[ "$actual" -ne 0 ]]; then
        echo "  ok  $desc"
        PASS=$((PASS + 1))
    else
        echo "  FAIL $desc (expected non-zero exit, got 0)"
        FAIL=$((FAIL + 1))
    fi
}

report_results() {
    echo ""
    echo "Results: $PASS passed, $FAIL failed"
    [[ $FAIL -eq 0 ]]
}
