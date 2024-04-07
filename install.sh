#!/bin/bash
set -euox pipefail

source "${GITHUB_ACTION_PATH:-.}/resolve.sh"

AUTOMAKE_TEMPDIR="${INPUTS_AUTOMAKE_TEMPDIR:-}"
if [ -z "${AUTOMAKE_TEMPDIR}" ]; then
  if [ -n "${RUNNER_TEMP:-}" ]; then
    AUTOMAKE_TEMPDIR="${RUNNER_TEMP:-}"
  else
    AUTOMAKE_TEMPDIR="$(mktemp -d)"
  fi
fi

AUTOMAKE_INSTALLDIR="${RUNNER_TOOL_CACHE:-${AUTOMAKE_TEMPDIR}}/automake/${VERSION}"

mkdir -p "${AUTOMAKE_INSTALLDIR}"

download() {
  echo '::group::📖 Download automake ...'
  curl --output "${AUTOMAKE_TEMPDIR}/automake.tar.gz" -sSL "http://ftpmirror.gnu.org/automake/automake-${VERSION}.tar.gz"
  curl --output "${AUTOMAKE_TEMPDIR}/automake.tar.gz.sig" -sSL "http://ftpmirror.gnu.org/automake/automake-${VERSION}.tar.gz.sig"
  curl --output "${AUTOMAKE_TEMPDIR}/gnu-keyring.gpg" -sSL "https://ftp.gnu.org/gnu/gnu-keyring.gpg"
  echo '::endgroup::'
  echo '::group::📖 gpg key import ...'
  gpg --import "${AUTOMAKE_TEMPDIR}/gnu-keyring.gpg"
  echo '::endgroup::'
  echo '::group::📖 Unarchive automake ...'
  gpg --verify "${AUTOMAKE_TEMPDIR}/automake.tar.gz.sig" "${AUTOMAKE_TEMPDIR}/automake.tar.gz"
  tar -zx -f "${AUTOMAKE_TEMPDIR}/automake.tar.gz" -C "${AUTOMAKE_TEMPDIR}/"
  echo '::endgroup::'
}

install() {
  if [ ! -f "${AUTOMAKE_INSTALLDIR}/bin/automake" ]; then
    download
    echo '::group::📖 Installing automake ...'
    cd "${AUTOMAKE_TEMPDIR}/automake-${VERSION}"
    ./configure --prefix="${AUTOMAKE_INSTALLDIR}"
    make -j"$(nproc)"
    make install
    echo "${AUTOMAKE_INSTALLDIR}/bin" >> "${GITHUB_PATH:-/dev/null}"
    echo '::endgroup::'
  fi
}

install
