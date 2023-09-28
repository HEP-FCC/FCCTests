#!/bin/bash

source ${FCCTESTS_STACK}

podio-dump "${FCCTESTS_INFILE}"
exit $?
