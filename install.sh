#!/bin/bash
set -euo pipefail

source "${GITHUB_ACTION_PATH:-.}/resolve.sh"

mkdir -p "${AUTOMAKE_INSTALLDIR}"

report() {
  # Report log
  echo "::group::📋 Report"
  cat config.log || true
  echo "::endgroup::"
}

install() {
  echo '::group::📖 Installing automake ...'
  cd "${AUTOMAKE_TEMPDIR}/automake-${VERSION}"
  ./configure --prefix="${AUTOMAKE_INSTALLDIR}" || (report && exit 1)
  make -j"$(nproc)"
  make install
  echo '::endgroup::'
}

install

echo "${AUTOMAKE_INSTALLDIR}/bin" >> "${GITHUB_PATH:-/dev/null}"
