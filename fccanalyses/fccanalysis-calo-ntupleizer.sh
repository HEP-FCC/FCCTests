#!/bin/bash

source "${FCCTESTS_STACK}"

RNDMSTR="$(sed 's/[-]//g' < /proc/sys/kernel/random/uuid | head -c 12)"
WORKDIR="${FCCTESTS_TMPDIR}/fccanalysis-calo-ntupleizer-${RNDMSTR}"

mkdir -p "${WORKDIR}" || exit 1
cd "${WORKDIR}" || exit 1

# Run simulation
ddsim --enableGun \
      --gun.distribution uniform \
      --gun.energy "10*GeV" \
      --gun.particle e- \
      --numberOfEvents 100 \
      --outputFile ALLEGRO_sim.root \
      --random.enableEventSeed \
      --random.seed 42 \
      --compactFile $K4GEO/FCCee/ALLEGRO/compact/ALLEGRO_o1_v02/ALLEGRO_o1_v02.xml || exit 1

# Run digitization and reconstruction
FCCURL="http://fccsw.web.cern.ch/fccsw/filesForSimDigiReco"
mkdir data || exit 1
cd data || exit 1
curl -O -L ${FCCURL}/ALLEGRO/ALLEGRO_o1_v02/elecNoise_ecalBarrelFCCee_theta.root || exit 1
curl -O -L ${FCCURL}/ALLEGRO/ALLEGRO_o1_v02/cellNoise_map_electronicsNoiseLevel_thetamodulemerged.root || exit 1
curl -O -L ${FCCURL}/ALLEGRO/ALLEGRO_o1_v02/neighbours_map_barrel_thetamodulemerged.root || exit 1
cd ..

curl -O -L https://raw.githubusercontent.com/HEP-FCC/FCC-config/main/FCCee/FullSim/ALLEGRO/ALLEGRO_o1_v02/run_digi_reco.py || exit 1
k4run -n 10 run_digi_reco.py || exit 1

podio-dump ALLEGRO_sim_digi_reco.root || exit 1

python ${FCCANALYSES}/../share/examples/examples/FCCee/fullSim/caloNtupleizer/analysis.py \
       -geometryFile $K4GEO/FCCee/ALLEGRO/compact/ALLEGRO_o1_v02/ALLEGRO_o1_v02.xml \
       -readoutName ECalBarrelModuleThetaMerged2 \
       -genBranchName MCParticles \
       -inputFiles ALLEGRO_sim_digi_reco.root
