#!/bin/sh

get_pkg_name() {
	local DEB="${1}"; shift
	dpkg-deb --show "${DEB}" | awk '{print $1}'
}

#
# Arguments:
#	- path to the debian package
#
# Environment:
#	TMP_DIR: path to a working directory, that could be filled with content.
#
create_arch_linux_pkg() {
	local DEB_PATH="${1}"; shift
	local DEB="$(basename "${DEB_PATH}")"

	local PKG_NAME="`get_pkg_name "${DEB_PATH}"`"

	local TMP_PKG_DIR="${TMP_DIR}"/"${PKG_NAME}"

	rm -rf "${TMP_PKG_DIR}"
	mkdir "${TMP_PKG_DIR}"

	cp "${TEMPLATE_DIR}"/* "${TMP_PKG_DIR}"/

	find "${TMP_PKG_DIR}" -type f | while read FILE
	do
		sed 's:##DEB##:'"${DEB}"':g' -i "${FILE}"
		sed 's:##PKGNAME##:'"${PKG_NAME}"':g' -i "${FILE}"
	done

	(cd "${TMP_PKG_DIR}"; sh ./create-package)
	find "${TMP_PKG_DIR}" -maxdepth 1 -name "*.pkg.tar.xz" | while read FILE
	do
		cp -v "${FILE}" .
	done

	#rm -rf "${TMP_PKG_DIR}"
}

MY_PATH_ABS="$(readlink -e "${0}")"
MY_DIR_ABS="$(dirname "${MY_PATH_ABS}")"

TEMPLATE_DIR="${MY_DIR_ABS}"/template

TMP_DIR="$(mktemp -d)"

while [ ${#} -gt 0 ]
do
	DEB="${1}"; shift

	create_arch_linux_pkg "${DEB}"
done

rm -rf "${TMP_DIR}"
