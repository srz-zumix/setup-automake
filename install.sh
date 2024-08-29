#!/bin/bash
set -euo pipefail

source "${GITHUB_ACTION_PATH:-.}/resolve.sh"

AUTOMAKE_INSTALLDIR="${TOOL_INSTALLDIR}/automake"
AUTOMAKE_TEMPDIR="${TOOL_TEMPDIR}/automake"
mkdir -p "${AUTOMAKE_TEMPDIR}"
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
    if ! command -v autoconf >/dev/null 2>&1; then
      REQUIRED_AUTOCONF_VERSION=$(grep -o 'required_autoconf_version.*[0-9.]*[0-9]*' "${AUTOMAKE_TEMPDIR}/automake-${VERSION}/configure.ac" | head -1 | grep -o '[0-9.]*[0-9]*')
      "${GITHUB_ACTION_PATH:-.}/install-gnu-tool.sh" autoconf "${REQUIRED_AUTOCONF_VERSION}"
    fi
    echo '::group::📖 Installing automake ...'
    cd "${AUTOMAKE_TEMPDIR}/automake-${VERSION}"
    ./configure --prefix="${AUTOMAKE_INSTALLDIR}"
    make -j"$(nproc)"
    make install
    echo '::endgroup::'
  fi
}

install

echo "${AUTOMAKE_INSTALLDIR}/bin" >> "${GITHUB_PATH:-/dev/null}"
