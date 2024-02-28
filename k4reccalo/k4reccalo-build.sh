#!/bin/bash

source "${FCCTESTS_STACK}"

RNDMSTR="$(sed 's/[-]//g' < /proc/sys/kernel/random/uuid | head -c 12)"
WORKDIR="${FCCTESTS_TMPDIR}/k4reccalo-build-${RNDMSTR}"

mkdir -p "${WORKDIR}" || exit 1
cd "${WORKDIR}" || exit 1

git clone https://github.com/HEP-FCC/k4RecCalorimeter.git || exit 1
cd k4RecCalorimeter || exit 1

mkdir build install
cd build || exit 1
cmake -DCMAKE_INSTALL_PREFIX=../install .. || exit 1
make -j 32 || exit 1
make install || exit 1
make test -j 32
