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

TOOL_TEMPDIR="${INPUTS_TOOL_TEMPDIR:-}"
if [ -z "${TOOL_TEMPDIR}" ]; then
  if [ -n "${RUNNER_TEMP:-}" ]; then
    TOOL_TEMPDIR="${RUNNER_TEMP:-}"
  else
    TOOL_TEMPDIR="$(mktemp -d)"
  fi
fi

TOOL_INSTALLDIR="${RUNNER_TOOL_CACHE:-${TOOL_TEMPDIR}}/automake/${VERSION}"

echo "path=${TOOL_INSTALLDIR}" | tee -a "${GITHUB_OUTPUT:-/dev/null}"
