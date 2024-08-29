#!/bin/bash
set -euo pipefail

source "${GITHUB_ACTION_PATH:-.}/resolve.sh"

if [ -f "${AUTOMAKE_INSTALLDIR}/bin/automake" ]; then
  echo "installed=true"  | tee -a "${GITHUB_OUTPUT:-/dev/null}"
  echo "${AUTOMAKE_INSTALLDIR}/bin" >> "${GITHUB_PATH:-/dev/null}"
else
  echo "installed=false" | tee -a "${GITHUB_OUTPUT:-/dev/null}"
fi
