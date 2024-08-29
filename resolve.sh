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
  echo "version=${VERSION}"
}

if [ "${VERSION}" == 'latest' ] || (echo "${VERSION}" | grep '[*]'); then
  echo '::group::📖 Resolve automake version ...'
  resolve_version
  echo '::endgroup::'
fi

echo "version=${VERSION}" >> "${GITHUB_OUTPUT:-/dev/null}"

AUTOMAKE_TEMPDIR="${INPUTS_AUTOMAKE_TEMPDIR:-}"
if [ -z "${AUTOMAKE_TEMPDIR}" ]; then
  if [ -n "${RUNNER_TEMP:-}" ]; then
    AUTOMAKE_TEMPDIR="${RUNNER_TEMP:-}"
  else
    AUTOMAKE_TEMPDIR="$(mktemp -d)"
  fi
fi

AUTOMAKE_INSTALLDIR="${RUNNER_TOOL_CACHE:-${AUTOMAKE_TEMPDIR}}/automake/${VERSION}"

echo "path=${AUTOMAKE_INSTALLDIR}" >> "${GITHUB_OUTPUT:-/dev/null}"
