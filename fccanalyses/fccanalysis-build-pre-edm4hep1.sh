#!/bin/bash

# source "${FCCTESTS_STACK}"
source /cvmfs/sw.hsf.org/key4hep/setup.sh -r 2024-03-10

RNDMSTR="$(sed 's/[-]//g' < /proc/sys/kernel/random/uuid | head -c 12)"
WORKDIR="${FCCTESTS_TMPDIR}/fccanalyses-build-${RNDMSTR}"

mkdir -p "${WORKDIR}" || exit 1
cd "${WORKDIR}" || exit 1

git clone --branch pre-edm4hep1 https://github.com/HEP-FCC/FCCAnalyses.git || exit 1
cd FCCAnalyses || exit 1

source ./setup.sh
fccanalysis build -j 32
fccanalysis test -j 16

exit
