#!/bin/bash

source "${FCCTESTS_STACK}"

RNDMSTR="$(sed 's/[-]//g' < /proc/sys/kernel/random/uuid | head -c 12)"
WORKDIR="${FCCTESTS_TMPDIR}/fccanalyses-build-${RNDMSTR}"

mkdir -p "${WORKDIR}" || exit 1
cd "${WORKDIR}" || exit 1

mkdir -p "${WORKDIR}/old-ana-scripts" || exit 1
cd "${WORKDIR}/old-ana-scripts" || exit 1
git clone https://github.com/HEP-FCC/FCCAnalyses.git || exit 1
cd FCCAnalyses || exit 1
git checkout de84ccb53
cd ../..

git clone https://github.com/HEP-FCC/FCCAnalyses.git || exit 1
cd FCCAnalyses || exit 1

source ./setup.sh
fccanalysis build -j 32 || exit 1
fccanalysis run ../old-ana-scripts/FCCAnalyses/examples/FCCee/higgs/mH-recoil/mumu/analysis_stage1.py || exit 1
fccanalysis run ../old-ana-scripts/FCCAnalyses/examples/FCCee/higgs/mH-recoil/mumu/analysis_stage2.py || exit 1
fccanalysis final ../old-ana-scripts/FCCAnalyses/examples/FCCee/higgs/mH-recoil/mumu/analysis_final.py || exit 1
fccanalysis plots ../old-ana-scripts/FCCAnalyses/examples/FCCee/higgs/mH-recoil/mumu/analysis_plots.py
