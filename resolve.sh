#!/bin/bash
set -euo pipefail

VERSION="${INPUTS_VERSION:-latest}"

versions() {
  curl -sSL ftp://ftp.gnu.org/gnu/automake/ | grep -o 'automake-[0-9.]*.tar.gz' | grep -o '[0-9.]*[0-9]' | sort -V
}

resolve_version() {
  if [ "${VERSION}" == 'latest' ]; then
    VERSION=$(versions | tail -1)
  else
    VERSION=$(versions | grep "^${VERSION}\$" | tail -1)
  fi
}

if [ "${VERSION}" == 'latest' ] || (echo "${VERSION}" | grep '[*]'); then
  echo '::group::📖 Resolve automake version ...'
  resolve_version
  echo '::endgroup::'
fi

echo "version=${VERSION}" | tee -a "${GITHUB_OUTPUT:-/dev/null}"
