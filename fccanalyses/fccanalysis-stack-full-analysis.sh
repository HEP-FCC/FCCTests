#!/bin/bash

source "${FCCTESTS_STACK}"

RNDMSTR="$(sed 's/[-]//g' < /proc/sys/kernel/random/uuid | head -c 12)"
WORKDIR="${FCCTESTS_TMPDIR}/fccanalyses-stack-full-analysis-${RNDMSTR}"

mkdir -p "${WORKDIR}" || exit 1
cd "${WORKDIR}" || exit 1

fccanalysis run ${FCCANALYSES}/../share/examples/examples/FCCee/higgs/mH-recoil/mumu/analysis_stage1.py || exit 1
fccanalysis run ${FCCANALYSES}/../share/examples/examples/FCCee/higgs/mH-recoil/mumu/analysis_stage2.py || exit 1
fccanalysis final ${FCCANALYSES}/../share/examples/examples/FCCee/higgs/mH-recoil/mumu/analysis_final.py || exit 1
fccanalysis plots ${FCCANALYSES}/../share/examples/examples/FCCee/higgs/mH-recoil/mumu/analysis_plots.py
exit $?
