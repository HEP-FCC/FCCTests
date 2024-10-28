#!/bin/bash

source "${FCCTESTS_STACK}"

RNDMSTR="$(sed 's/[-]//g' < /proc/sys/kernel/random/uuid | head -c 12)"
WORKDIR="${FCCTESTS_TMPDIR}/fccanalysis-calo-ntupleizer-${RNDMSTR}"

mkdir -p "${WORKDIR}" || exit 1
cd "${WORKDIR}" || exit 1

# Make EOS accessible
echo "kinit -kt ${FCCTESTS_DIR}/fcc-tests.keytab ${USER} || exit 1"
kinit -kt ${FCCTESTS_DIR}/fcc-tests.keytab ${USER} || exit 1
aklog || exit 1

# Obtain FCC configuration files
git clone git@github.com:HEP-FCC/FCC-config.git || exit 1
cd FCC-config/FCCee/FullSim/ALLEGRO/ALLEGRO_o1_v03 || exit 1

# Enable saving of ECal hits and cells
sed -i 's/saveHits = False/saveHits = True/g' run_digi_reco.py
sed -i 's/saveCells = False/saveCells = True/g' run_digi_reco.py

# Run the ALLEGRO test to obtain input file
./ctest_sim_digi_reco.sh

# Dump reco file
podio-dump ALLEGRO_sim_digi_reco.root || exit 1
cp ALLEGRO_sim_digi_reco.root "${WORKDIR}/" || exit 1
cd "${WORKDIR}" || exit 1

# Obtain FCCAnalyses
git clone https://github.com/HEP-FCC/FCCAnalyses.git || exit 1
cd FCCAnalyses || exit 1

# Build FCCAnalyses
source ./setup.sh
fccanalysis build -j 32

# Run analysis
python examples/FCCee/fullSim/caloNtupleizer/analysis.py \
       -geometryFile $K4GEO/FCCee/ALLEGRO/compact/ALLEGRO_o1_v03/ALLEGRO_o1_v03.xml \
       -readoutName ECalBarrelModuleThetaMerged2 \
       -cellBranchNames ECalBarrelModuleThetaMergedPositioned \
       -genBranchName MCParticles \
       -inputFiles ../ALLEGRO_sim_digi_reco.root
