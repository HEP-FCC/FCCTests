#!/bin/bash

set -e

source "${FCCTESTS_STACK}"

WORKDIR="${FCCTESTS_TMPDIR}/fccanalyses-build-${FCCTESTS_RNDMSTR}"

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

git clone "${FCCTESTS_FCCANALYSES_REPO}" -b "${FCCTESTS_FCCANALYSES_BRANCH}"
cd FCCAnalyses

mkdir build install
cd build
cmake -DCMAKE_INSTALL_PREFIX=../install -DWITH_ACTS=ON ..
make -j 16
make install
make test -j 16
