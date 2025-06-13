#!/bin/bash

set -e

WORKDIR="${FCCTESTS_TMPDIR}/fccanalyses-build-${FCCTESTS_RNDMSTR}"

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

mkdir -p "${WORKDIR}/old-ana-scripts"
cd "${WORKDIR}/old-ana-scripts"
git clone https://github.com/HEP-FCC/FCCAnalyses.git
cd FCCAnalyses
git checkout de84ccb53
cd ../..

git clone --branch pre-edm4hep1 https://github.com/HEP-FCC/FCCAnalyses.git
cd FCCAnalyses

source ./setup.sh
fccanalysis build -j 16

fccanalysis run ../old-ana-scripts/FCCAnalyses/examples/FCCee/higgs/mH-recoil/mumu/analysis_stage1.py
fccanalysis run ../old-ana-scripts/FCCAnalyses/examples/FCCee/higgs/mH-recoil/mumu/analysis_stage2.py
fccanalysis final ../old-ana-scripts/FCCAnalyses/examples/FCCee/higgs/mH-recoil/mumu/analysis_final.py
fccanalysis plots ../old-ana-scripts/FCCAnalyses/examples/FCCee/higgs/mH-recoil/mumu/analysis_plots.py
