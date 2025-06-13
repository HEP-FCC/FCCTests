#!/bin/bash

set -e

WORKDIR="${FCCTESTS_TMPDIR}/fccanalyses-build-${FCCTESTS_RNDMSTR}"

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

git clone --branch pre-edm4hep1 "${FCCTESTS_FCCANALYSES_REPO}"
cd FCCAnalyses

source ./setup.sh
fccanalysis build -j 16
fccanalysis test -j 16
