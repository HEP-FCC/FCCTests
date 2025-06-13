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

fccanalysis run examples/FCCee/higgs/mH-recoil/mumu/analysis_stage1.py
fccanalysis run examples/FCCee/higgs/mH-recoil/mumu/analysis_stage2.py
fccanalysis final examples/FCCee/higgs/mH-recoil/mumu/analysis_final.py
fccanalysis plots examples/FCCee/higgs/mH-recoil/mumu/analysis_plots.py
