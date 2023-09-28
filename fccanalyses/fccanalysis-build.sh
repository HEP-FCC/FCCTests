#!/bin/bash

source "${FCCTESTS_STACK}"

RNDMSTR="$(sed 's/[-]//g' < /proc/sys/kernel/random/uuid | head -c 12)"
WORKDIR="${FCCTESTS_TMPDIR}/build-fccanalyses-${RNDMSTR}"

mkdir -p "${WORKDIR}"
cd "${WORKDIR}" || exit 1

git clone git@github.com:HEP-FCC/FCCAnalyses.git
cd FCCAnalyses || exit 1

mkdir build install
cd build || exit 1
cmake -DCMAKE_INSTALL_PREFIX=../install .. || exit $?
make -j 32 || exit $?
make install || exit $?
make test || exit $?

exit $?
