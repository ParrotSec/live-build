#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2016-2020 The Debian Live team
## Copyright (C) 2006-2015 Daniel Baumann <mail@daniel-baumann.ch>
##
## This program comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.

# Updates FIRMWARE_PACKAGES with list of packages determined from specified
# archive areas of specified distro, based upon reading archive content file.
#
# Shared by chroot_firmware and installer_debian-installer
#
# Assumption: firmware packages install files into /lib/firmware
Firmware_List_From_Contents () {
	local MIRROR_CHROOT="${1}"
	local DISTRO_CHROOT="${2}"
	local ARCHIVE_AREAS="${3}"

	local _ARCHIVE_AREA
	for _ARCHIVE_AREA in ${ARCHIVE_AREAS}
	do
		local CONTENTS_FILEDIR="cache/contents.chroot/${DISTRO_CHROOT}/${_ARCHIVE_AREA}"
		mkdir -p "${CONTENTS_FILEDIR}"

		local _ARCH
		for _ARCH in all ${LB_ARCHITECTURE}
		do
			local CONTENTS_URL="${MIRROR_CHROOT}/dists/${DISTRO_CHROOT}/${_ARCHIVE_AREA}/Contents-${_ARCH}.gz"
			local CONTENTS_FILE="${CONTENTS_FILEDIR}/contents-${_ARCH}.gz"

			# Purge from cache if not wanting to use from cache, ensuring fresh copy
			if [ "${LB_CACHE}" != "true" ]
			then
				rm -f "${CONTENTS_FILE}"
			fi

			# If not cached, download
			if [ ! -e "${CONTENTS_FILE}" ]
			then
				# Contents-all.gz does not exist in Buster and other older versions
				if ! wget --quiet --spider ${WGET_OPTIONS} "${CONTENTS_URL}"; then
					continue
				fi
				wget ${WGET_OPTIONS} "${CONTENTS_URL}" -O "${CONTENTS_FILE}"
			fi

			local PACKAGES
			PACKAGES="$(gunzip -c "${CONTENTS_FILE}" | awk '/^lib\/firmware/ { print $2 }' | sort -u )"
			FIRMWARE_PACKAGES="${FIRMWARE_PACKAGES} ${PACKAGES}"

			# Don't waste disk space, if not making use of caching
			if [ "${LB_CACHE}" != "true" ]
			then
				rm -f "${CONTENTS_FILE}"
			fi
		done
	done
}
