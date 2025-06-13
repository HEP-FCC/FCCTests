#!/bin/bash

set -e

source "${FCCTESTS_STACK}"

WORKDIR="${FCCTESTS_TMPDIR}/fccanalyses-build-${FCCTESTS_RNDMSTR}"

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

git clone "${FCCTESTS_FCCANALYSES_REPO}" -b "${FCCTESTS_FCCANALYSES_BRANCH}"
cd FCCAnalyses

source ./setup.sh
fccanalysis build -j 16
fccanalysis test -j 16
