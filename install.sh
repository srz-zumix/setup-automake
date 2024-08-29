#!/bin/bash
set -euo pipefail

source "${GITHUB_ACTION_PATH:-.}/resolve.sh"

mkdir -p "${AUTOMAKE_INSTALLDIR}"

install() {
  echo '::group::📖 Installing automake ...'
  cd "${AUTOMAKE_TEMPDIR}/automake-${VERSION}"
  ./configure --prefix="${AUTOMAKE_INSTALLDIR}"
  make -j"$(nproc)"
  make install
  echo '::endgroup::'
}

install

echo "${AUTOMAKE_INSTALLDIR}/bin" >> "${GITHUB_PATH:-/dev/null}"
