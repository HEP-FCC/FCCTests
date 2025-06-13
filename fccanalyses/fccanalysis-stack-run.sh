#!/bin/bash

set -e

source "${FCCTESTS_STACK}"

WORKDIR="${FCCTESTS_TMPDIR}/fccanalyses-stack-run-${FCCTESTS_RNDMSTR}"

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

fccanalysis run --test ${FCCANALYSES}/../share/examples/examples/FCCee/higgs/mH-recoil/mumu/analysis_stage1.py
