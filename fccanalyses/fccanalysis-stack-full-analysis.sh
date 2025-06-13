#!/bin/bash

set -e

source "${FCCTESTS_STACK}"

WORKDIR="${FCCTESTS_TMPDIR}/fccanalyses-stack-full-analysis-${FCCTESTS_RNDMSTR}"

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

fccanalysis run ${FCCANALYSES}/../share/examples/examples/FCCee/higgs/mH-recoil/mumu/analysis_stage1.py
fccanalysis run ${FCCANALYSES}/../share/examples/examples/FCCee/higgs/mH-recoil/mumu/analysis_stage2.py
fccanalysis final ${FCCANALYSES}/../share/examples/examples/FCCee/higgs/mH-recoil/mumu/analysis_final.py
fccanalysis plots ${FCCANALYSES}/../share/examples/examples/FCCee/higgs/mH-recoil/mumu/analysis_plots.py
