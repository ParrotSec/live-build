#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2006-2015 Daniel Baumann <mail@daniel-baumann.ch>
##
## This program comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


Chroot ()
{
	CHROOT="${1}"; shift
	COMMANDS="${@}"

	# Executing commands in chroot
	Echo_debug "Executing: %s" "${COMMANDS}"

	ENV=""

	for _FILE in config/environment config/environment.chroot
	do
		if [ -e "${_FILE}" ]
		then
			ENV="${ENV} $(grep -v '^#' ${_FILE})"
		fi
	done

	# Only pass SOURCE_DATE_EPOCH if its already set
	if [ "${SOURCE_DATE_EPOCH:-}" != "" ]
	then
		ENV="${ENV} SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH}"
	fi

	${_LINUX32} chroot "${CHROOT}" /usr/bin/env -i HOME="/root" PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin" TERM="${TERM}" DEBIAN_FRONTEND="${LB_DEBCONF_FRONTEND}" DEBIAN_PRIORITY="${LB_DEBCONF_PRIORITY}" DEBCONF_NONINTERACTIVE_SEEN="true" DEBCONF_NOWARNINGS="true" ${ENV} ${COMMANDS}

	return "${?}"
}

Chroot_has_package() {
	PACKAGE="${1}"; shift
	CHROOT="${2:-chroot}"; shift

	if dpkg-query --admindir=${CHROOT}/var/lib/dpkg -s ${PACKAGE} >/dev/null 2>&1 | grep -q "^Status: install"
	then
		return 0
	fi
	return 1
}

Chroot_package_list() {
	CHROOT="${1:-chroot}"; shift

	dpkg-query --admindir=${CHROOT}/var/lib/dpkg -W -f'${Package}\n'
}
