#!/usr/bin/env bash
set -euo pipefail

PYTHON_BIN=""
if [[ -x ".venv/bin/python3" ]]; then
  PYTHON_BIN=".venv/bin/python3"
elif command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="python3"
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN="python"
else
  echo "Error: python3 (or python) not found. Activate your venv first." >&2
  exit 127
fi

"$PYTHON_BIN" -m uvicorn api.main:app --host 0.0.0.0 --port "${PORT:-8000}"
