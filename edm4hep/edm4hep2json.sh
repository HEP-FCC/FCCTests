#!/bin/bash

source "${FCCTESTS_STACK}"

edm4hep2json -n 5 \
             -l ReconstructedParticles \
             -o "${FCCTESTS_TMPDIR}/test-edm4hep2json-output.edm4hep.json" \
             "${FCCTESTS_INFILE}"
exit $?
