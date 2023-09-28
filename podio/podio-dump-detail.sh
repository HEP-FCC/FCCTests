#!/bin/bash

source ${FCCTESTS_STACK}

podio-dump -d "${FCCTESTS_INFILE}"
exit $?
