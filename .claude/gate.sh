#!/usr/bin/env bash
# Deterministic gate — enforced by the Stop hook (verification-gate.py) and /code-check.
# Keep under 2 minutes. Plan: familiar/docs/plans/2026-09-01-siloed-verification-hook-enforcement.md
set -e
cd "$(dirname "$0")/.."
cd secrets && python3 -m pytest -q --ignore=tests/test_e2e.py  # e2e needs 1Password auth; run from secrets/ so haunt_secrets imports
