#!/bin/bash
set -euo pipefail

TOOL_NAME=$1
TARGET_VERSION=$2
TARGET_TOOL_INSTALLDIR="${TOOL_INSTALLDIR}/${TOOL_NAME}"
TARGET_TOOL_TEMPDIR="${TOOL_TEMPDIR}/${TOOL_NAME}"

mkdir -p "${TOOL_TEMPDIR}"
mkdir -p "${TARGET_TOOL_INSTALLDIR}"

download() {
  echo "::group::📖 Download ${TOOL_NAME} ..."
  curl --output "${TARGET_TOOL_TEMPDIR}/${TOOL_NAME}.tar.gz" -sSL "http://ftpmirror.gnu.org/${TOOL_NAME}/${TOOL_NAME}-${TARGET_VERSION}.tar.gz"
  curl --output "${TARGET_TOOL_TEMPDIR}/${TOOL_NAME}.tar.gz.sig" -sSL "http://ftpmirror.gnu.org/${TOOL_NAME}/${TOOL_NAME}-${TARGET_VERSION}.tar.gz.sig"
  echo '::endgroup::'
  echo "::group::📖 Unarchive ${TOOL_NAME} ..."
  gpg --verify "${TARGET_TOOL_TEMPDIR}/${TOOL_NAME}.tar.gz.sig" "${TARGET_TOOL_TEMPDIR}/${TOOL_NAME}.tar.gz"
  tar -zx -f "${TARGET_TOOL_TEMPDIR}/${TOOL_NAME}.tar.gz" -C "${TARGET_TOOL_TEMPDIR}/"
  echo '::endgroup::'
}

install() {
  if [ ! -f "${TARGET_TOOL_INSTALLDIR}/bin/${TOOL_NAME}" ]; then
    download
    echo "::group::📖 Installing ${TOOL_NAME} ..."
    cd "${TARGET_TOOL_TEMPDIR}/${TOOL_NAME}-${TARGET_VERSION}"
    ./configure --prefix="${TARGET_TOOL_INSTALLDIR}"
    make -j"$(nproc)"
    make install
    echo '::endgroup::'
  fi
}

install

echo "${TARGET_TOOL_INSTALLDIR}/bin" >> "${GITHUB_PATH:-/dev/null}"
