#!/bin/bash

set -e

if [[ ! "$(command -v wget gpg shasum dpkg)" ]]; then
	echo ">>> Missing one of requited commands: wget gpg shasum dpkg"
	exit 1
fi

KERNEL_REPO_URL=https://kernel.ubuntu.com/~kernel-ppa/mainline
ARCH="$(dpkg --print-architecture)"
VERSION="latest"
INSTALL_OPS=""
DOWNLOAD_OPS="-nv"
INSTALL_CONFIRMED=1

POSITIONAL=()
while [[ $# -gt 0 ]]; do
        case "${1}" in
		--dry-run)
			echo ">>> Executing in dry-run mode"
			INSTALL_OPS="--dry-run"
			DOWNLOAD_OPS="-nv --spider"
			shift
			;;
		-y|--yes)
			echo ">>> Executing in auto-confirmation mode"
			INSTALL_CONFIRMED=0
			shift
			;;
                *)
			POSITIONAL+=("${1}")
			shift
			;;
        esac
done

# restore positional parameters
set -- "${POSITIONAL[@]}"

if [[ $# -gt 0 ]]; then
	# TODO: check for semantic version or 'latest'
	VERSION="${1}"
fi

if [[ "${VERSION}" == "latest" ]]; then
	echo ">>> Resolving latest kernel version"
	VERSION=$(
	wget -qO- "${KERNEL_REPO_URL}" | \
		grep -Eoi '<a [^>]+>' | \
		grep -Eo 'href="[^\"]+"' | \
		grep -Eo '(v[0-9]+\.[0-9]+\.[0-9]+)[^\"/]*' | \
		sed 's\^v\\g' | \
		sort -V | \
		tail -n1
	)
fi

VERSION_TAG=$(echo "${VERSION}" | sed -e 's/\b[0-9]\b/0&/g' | sed 's/\.//g')

echo ">>> System info: $(uname -a)"
CURRENT_KERNEL=$(uname -r)
if [[ "${CURRENT_KERNEL}" == ${VERSION}* ]]; then
	echo ">>> Kernel is already up to date: ${CURRENT_KERNEL}"
	exit 0
else
	echo ">>> Upgrading kernel ${CURRENT_KERNEL} to ${VERSION}"
fi

DOWNLOAD_URL="${KERNEL_REPO_URL}/v${VERSION}/${ARCH}"
DOWNLOAD_DIR="/tmp/kernel_${VERSION_TAG}"

echo ">>> Downloading kernel packages"
# 1. List all resources from Ubuntu mainline kernel repo
# 2. Filter out 'lowlatency' packages
# 3. Prepend mainline repo URL
# 4. Dowload all to DOWNLOAD_DIR
wget -qO- "${DOWNLOAD_URL}" | \
	grep -Eoi '<a [^>]+>' | \
	grep -Eo 'href="[^\"]+"' | \
	grep -Eo '(CHECKSUMS|CHECKSUMS.gpg|linux-)[^\"]*' | \
	grep -v 'lowlatency' | \
	awk -vURL="${DOWNLOAD_URL}" '{print URL "/" $0}' | \
	xargs wget ${DOWNLOAD_OPS} -P "${DOWNLOAD_DIR}"

#echo ">>> Verifying checksums"
#if [[ ! $(gpg --list-keys | grep -w 60AA7B6F30434AE68E569963E50C6A0917C622B0) ]]; then
#	gpg --keyserver hkps://pgp.mit.edu --recv-key 60AA7B6F30434AE68E569963E50C6A0917C622B0
#fi
#gpg --verify "${DOWNLOAD_DIR}/CHECKSUMS.gpg" "${DOWNLOAD_DIR}/CHECKSUMS"
#shasum -c "${DOWNLOAD_DIR}/CHECKSUMS" 2>&1 | grep 'OK$'

echo ">>> Installing kernel v${VERSION}"
if [[ -d "${DOWNLOAD_DIR}" ]]; then
	echo ">>> Found new kernel packages in '${DOWNLOAD_DIR}'"

	if [[ "${INSTALL_CONFIRMED}" -eq 0 ]]; then
		# TODO: pass yes to dpkg (like `yes | dpkg -i ...`)
		sudo dpkg ${INSTALL_OPS} -i -R "${DOWNLOAD_DIR}"
	else
		read -p ">>> Do you want to proceed with installation? (yY/nN): " -n 1 -r
		echo    # move to a new line
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			sudo dpkg ${INSTALL_OPS} -i -R "${DOWNLOAD_DIR}"
		fi
	fi

	echo ">>> Removing download directory '${DOWNLOAD_DIR}'"
	rm -rf "${DOWNLOAD_DIR}"

	echo ">>> Installation done, reboot to apply kernel update"
else
	echo ">>> Directory '${DOWNLOAD_DIR}' does not exist, skipping installation"
fi
