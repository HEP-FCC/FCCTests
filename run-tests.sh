#!/bin/bash

#
# Global setup
#
export FCCTESTS_SCRIPTPATH=$(realpath "$0")
export FCCTESTS_DIR=$(dirname "${FCCTESTS_SCRIPTPATH}")
export FCCTESTS_TMPDIR=/tmp/fcc-tests

LOGDIR_STEM="${FCCTESTS_TMPDIR}/log"
SUMMARYFILE="${FCCTESTS_TMPDIR}/fcc-test-summary.txt"
MAILFILE="${FCCTESTS_TMPDIR}/fcc-test-mail.txt"

MAILLISTFILE=${FCCTESTS_DIR}/emails.lst
RUNDATE=$(date)
NFAILURES=0

: > ${SUMMARYFILE}  # Clearing summary file
rm -rf ${FCCTESTS_TMPDIR}
mkdir -p "${FCCTESTS_TMPDIR}"


declare -A STACKS=(
  ["stable"]="/cvmfs/sw.hsf.org/key4hep/setup.sh"
  ["nightlies"]="/cvmfs/sw-nightlies.hsf.org/key4hep/setup.sh"
)

#
# Run tests
#

#
# Podio/EDM4hep tests
#
declare -A EDM4HEPINFILES=(
  # ["spring-2021"]="/eos/experiment/fcc/ee/generation/DelphesEvents/spring2021/IDEA/p8_ee_ZH_ecm240/events_101027117.root"
  # ["winter-2023"]="/eos/experiment/fcc/ee/generation/DelphesEvents/winter2023/IDEA/p8_ee_ZZ_ecm240/events_092194859.root"
)

declare -a EDM4HEPTESTS=(
  # podio/podio-dump
  # podio/podio-dump-detail
  # edm4hep/edm4hep2json
)

for TEST in "${EDM4HEPTESTS[@]}"; do
  for STACK in "${!STACKS[@]}"; do
    export FCCTESTS_STACK=${STACKS[$STACK]}

    for INFILE in "${!EDM4HEPINFILES[@]}"; do
      export FCCTESTS_INFILE=${EDM4HEPINFILES[$INFILE]}

      LOGDIR="${LOGDIR_STEM}/${TEST}/${STACK}/${INFILE}"
      mkdir -p "${LOGDIR}"

      echo $(date) > "${LOGDIR}/out.log"
      if ! bash "${FCCTESTS_DIR}/${TEST}.sh" >> "${LOGDIR}/out.log" 2> "${LOGDIR}/err.log"; then
        NFAILURES=$((NFAILURES+1))

        echo -e "\n[FAILURE]  ${TEST}" | tee -a ${SUMMARYFILE} 1>&2
        echo "    Stack:  ${STACK}" | tee -a ${SUMMARYFILE} 1>&2
        echo "    Campaign: ${INFILE}" | tee -a ${SUMMARYFILE} 1>&2
      else
        echo -e "\n[SUCCESS]  ${TEST}" | tee -a ${SUMMARYFILE} 1>&2
        echo "    Stack:  ${STACK}" | tee -a ${SUMMARYFILE} 1>&2
        echo "    Campaign: ${INFILE}" | tee -a ${SUMMARYFILE} 1>&2
      fi

      echo $(date) >> "${LOGDIR}/out.log"
    done
  done

  echo "---" | tee -a ${SUMMARYFILE} 1>&2
done
echo


#
# FCCAnalyses tests
#
declare -a FCCANATESTS=(
  fccanalyses/fccanalysis-build
  fccanalyses/fccanalysis-build-pre-edm4hep1
  fccanalyses/fccanalysis-build-cmake
  fccanalyses/fccanalysis-build-acts-on
  fccanalyses/fccanalysis-build-full-analysis
  fccanalyses/fccanalysis-build-full-analysis-user-args
  fccanalyses/fccanalysis-build-full-analysis-old-anascripts
  fccanalyses/fccanalysis-build-full-analysis-pre-edm4hep1
  fccanalyses/fccanalysis-build-full-analysis-pre-edm4hep1-old-anascripts
  fccanalyses/fccanalysis-stack-help
  fccanalyses/fccanalysis-stack-run
  fccanalyses/fccanalysis-stack-full-analysis
  fccanalyses/fccanalysis-build-calo-ntupleizer
  fccanalyses/fccanalysis-stack-calo-ntupleizer
)

for TEST in "${FCCANATESTS[@]}"; do
  for STACK in "${!STACKS[@]}"; do
    export FCCTESTS_STACK=${STACKS[$STACK]}
    export FCCTESTS_RNDMSTR="$(sed 's/[-]//g' < /proc/sys/kernel/random/uuid | head -c 12)"
    export FCCTESTS_FCCANALYSES_REPO="https://github.com/HEP-FCC/FCCAnalyses.git"
    export FCCTESTS_FCCANALYSES_BRANCH="master"

    LOGDIR="${LOGDIR_STEM}/${TEST}/${STACK}"
    mkdir -p "${LOGDIR}"

    echo $(date) > "${LOGDIR}/out.log"

    if ! bash "${FCCTESTS_DIR}/${TEST}.sh" >> "${LOGDIR}/out.log" 2> "${LOGDIR}/err.log"; then
      NFAILURES=$((NFAILURES+1))

      echo -e "\n[FAILURE]  ${TEST}" | tee -a ${SUMMARYFILE} 1>&2
    else
      echo -e "\n[SUCCESS]  ${TEST}" | tee -a ${SUMMARYFILE} 1>&2
    fi
    echo "           Stack:      ${STACK}" | tee -a ${SUMMARYFILE} 1>&2
    echo "           Reference:  ${FCCTESTS_RNDMSTR}" | tee -a ${SUMMARYFILE} 1>&2

    echo $(date) >> "${LOGDIR}/out.log"
  done

  echo "---" | tee -a ${SUMMARYFILE} 1>&2
done


#
# Send email(s)
#

if [ "${NFAILURES}" -eq "0" ]; then
  echo "Subject: FCC Tests: All tests succeeded" > ${MAILFILE}
else
  echo "Subject: FCC Tests: ${NFAILURES} failures" > ${MAILFILE}
fi
{
  echo -e "Hi,\n"
  echo -e "The tests run at ${RUNDATE}, and there were ${NFAILURES} failures.\n"
} >> ${MAILFILE}
cat ${SUMMARYFILE} >> ${MAILFILE}

if [ ! -f "${MAILLISTFILE}" ]; then
  echo "Can't find email list file: ${MAILLISTFILE}" | tee -a ${SUMMARYFILE} 1>&2
  exit 1
fi

readarray -t EMAILS < "${MAILLISTFILE}"

if [ "${#EMAILS[@]}" -lt 1 ]; then
  echo "Email list file is probably empty!" | tee -a ${SUMMARYFILE} 1>&2
  exit 1
fi

/usr/sbin/sendmail -t "${EMAILS[@]}" < ${MAILFILE}
