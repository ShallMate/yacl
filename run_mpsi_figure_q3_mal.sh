#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNNER="${SCRIPT_DIR}/examples/mpsi/run_figure_q3.sh"

usage() {
  cat <<'EOF'
Usage:
  ./run_mpsi_figure_q3_mal.sh

Runs the MPSI online benchmark in malicious mode only:
  1. N in {3,6,9,12,15}, t=1
  2. N in {3,6,9,12,15}, t=N-1
  3. N=15, t in {1,4,7,11,14}

Defaults:
  MPSI_LOGN=16
  OUT_DIR=./mpsi_figure_q3_mal
  SUMMARY_CSV=$OUT_DIR/figure_q3_mal.csv

Other environment variables are forwarded to examples/mpsi/run_figure_q3.sh.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ ! -x "${RUNNER}" ]]; then
  echo "runner not found or not executable: ${RUNNER}" >&2
  exit 1
fi

export MPSI_MODES="mal"
export OUT_DIR="${OUT_DIR:-${SCRIPT_DIR}/mpsi_figure_q3_mal}"
export SUMMARY_CSV="${SUMMARY_CSV:-${OUT_DIR}/figure_q3_mal.csv}"

exec "${RUNNER}" "$@"
