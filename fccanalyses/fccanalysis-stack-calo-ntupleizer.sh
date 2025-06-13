#!/bin/bash

set -e

source "${FCCTESTS_STACK}"

WORKDIR="${FCCTESTS_TMPDIR}/fccanalysis-calo-ntupleizer-${FCCTESTS_RNDMSTR}"

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Make EOS accessible
echo "kinit -kt ${FCCTESTS_DIR}/fcc-tests.keytab ${USER}"
kinit -kt ${FCCTESTS_DIR}/fcc-tests.keytab ${USER}
aklog

# Obtain FCC configuration files
git clone git@github.com:HEP-FCC/FCC-config.git
cd FCC-config/FCCee/FullSim/ALLEGRO/ALLEGRO_o1_v03

# Enable saving of ECal hits and cells
sed -i 's/saveHits = False/saveHits = True/g' run_digi_reco.py
sed -i 's/saveCells = False/saveCells = True/g' run_digi_reco.py

# Run the ALLEGRO test to obtain input file
./ctest_sim_digi_reco.sh

# Dump reco file
podio-dump ALLEGRO_sim_digi_reco.root
cp ALLEGRO_sim_digi_reco.root "${WORKDIR}/"
cd "${WORKDIR}"

# Run analysis
python ${FCCANALYSES}/../share/examples/examples/FCCee/fullSim/caloNtupleizer/analysis.py \
       -geometryFile $K4GEO/FCCee/ALLEGRO/compact/ALLEGRO_o1_v03/ALLEGRO_o1_v03.xml \
       -readoutName ECalBarrelModuleThetaMerged2 \
       -cellBranchNames ECalBarrelModuleThetaMergedPositioned \
       -genBranchName MCParticles \
       -inputFiles ALLEGRO_sim_digi_reco.root
