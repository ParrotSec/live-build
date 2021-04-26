#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2016-2020 The Debian Live team
## Copyright (C) 2006-2015 Daniel Baumann <mail@daniel-baumann.ch>
##
## This program comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


PROGRAM_NAME="live-build"
FRONTEND="lb"
PROGRAM="${FRONTEND} $(basename "${0}")"
VERSION="$(if [ -e ${LIVE_BUILD}/debian/changelog ]; then sed -e 's/.*(\(.*\)).*/\1/; s/^[0-9]://; q' ${LIVE_BUILD}/debian/changelog; else cat /usr/share/live/build/VERSION; fi)"

LIVE_BUILD_VERSION="${VERSION}"

PATH="${PWD}/local/bin:${PATH}"
