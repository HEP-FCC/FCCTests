#!/bin/bash

set -e

WORKDIR="${FCCTESTS_TMPDIR}/fccanalyses-build-${FCCTESTS_RNDMSTR}"

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

git clone --branch pre-edm4hep1 https://github.com/HEP-FCC/FCCAnalyses.git
cd FCCAnalyses

source ./setup.sh
fccanalysis build -j 16
fccanalysis test -j 16

fccanalysis run examples/FCCee/higgs/mH-recoil/mumu/analysis_stage1.py
fccanalysis run examples/FCCee/higgs/mH-recoil/mumu/analysis_stage2.py
fccanalysis final examples/FCCee/higgs/mH-recoil/mumu/analysis_final.py
fccanalysis plots examples/FCCee/higgs/mH-recoil/mumu/analysis_plots.py
