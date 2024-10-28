#!/bin/bash

source "${FCCTESTS_STACK}"

RNDMSTR="$(sed 's/[-]//g' < /proc/sys/kernel/random/uuid | head -c 12)"
WORKDIR="${FCCTESTS_TMPDIR}/fccanalyses-build-${RNDMSTR}"

mkdir -p "${WORKDIR}" || exit 1
cd "${WORKDIR}" || exit 1

git clone https://github.com/HEP-FCC/FCCAnalyses.git || exit 1
cd FCCAnalyses || exit 1

source ./setup.sh
fccanalysis build -j 32 || exit 1

fccanalysis run examples/FCCee/higgs/mH-recoil/mumu/analysis_stage1.py \
                --muon-pt 25 || exit 1
mv outputs/FCCee/higgs/mH-recoil/mumu/stage1_25.0 outputs/FCCee/higgs/mH-recoil/mumu/stage1_10.0
fccanalysis run examples/FCCee/higgs/mH-recoil/mumu/analysis_stage2.py || exit 1
fccanalysis final examples/FCCee/higgs/mH-recoil/mumu/analysis_final.py || exit 1
fccanalysis plots examples/FCCee/higgs/mH-recoil/mumu/analysis_plots.py

exit $?
