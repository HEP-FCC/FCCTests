#!/bin/bash

source "${FCCTESTS_STACK}"

RNDMSTR="$(sed 's/[-]//g' < /proc/sys/kernel/random/uuid | head -c 12)"
WORKDIR="${FCCTESTS_TMPDIR}/fccanalyses-build-${RNDMSTR}"

mkdir -p "${WORKDIR}" || exit 1
cd "${WORKDIR}" || exit 1

git clone https://github.com/HEP-FCC/FCCAnalyses.git || exit 1
cd FCCAnalyses || exit 1

source ./setup.sh
fccanalysis build -j 16
fccanalysis test -j 16

exit
