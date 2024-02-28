#!/bin/bash

#
# Global setup
#
declare -A STACKS=(
  ["stable"]="/cvmfs/sw.hsf.org/key4hep/setup.sh"
  ["nightlies"]="/cvmfs/sw-nightlies.hsf.org/key4hep/setup.sh"
)

export FCCTESTS_TMPDIR=/tmp/fcc-tests
export LOGDIR_STEM="$FCCTESTS_TMPDIR/log"

SUMMARYFILE=/tmp/fcc-test-summary.txt
MAILFILE=/tmp/fcc-test-mail.txt

WORKDIR=$(dirname -- "$0")
MAILLISTFILE=${WORKDIR}/emails.lst
RUNDATE=$(date)
NFAILURES=0

: > ${SUMMARYFILE}  # Clearing summary file
rm -rf ${FCCTESTS_TMPDIR}
mkdir -p "${FCCTESTS_TMPDIR}"


#
# Run tests
#

#
# Podio/EDM4hep tests
#
declare -A EDM4HEPINFILES=(
  ["spring-2021"]="/eos/experiment/fcc/ee/generation/DelphesEvents/spring2021/IDEA/p8_ee_ZH_ecm240/events_101027117.root"
  ["winter-2023"]="/eos/experiment/fcc/ee/generation/DelphesEvents/winter2023/IDEA/p8_ee_ZZ_ecm240/events_092194859.root"
)

declare -a EDM4HEPTESTS=(
  podio/podio-dump
  podio/podio-dump-detail
  edm4hep/edm4hep2json
)

for STACK in "${!STACKS[@]}"; do
  for INFILE in "${!EDM4HEPINFILES[@]}"; do
    export FCCTESTS_STACK=${STACKS[$STACK]}
    export FCCTESTS_INFILE=${EDM4HEPINFILES[$INFILE]}

    for TEST in "${EDM4HEPTESTS[@]}"; do
      LOGDIR="${LOGDIR_STEM}/${TEST}/${STACK}/${INFILE}"
      mkdir -p "${LOGDIR}"

      echo $(date) > "${LOGDIR}/out.log"
      if ! bash "${WORKDIR}/${TEST}.sh" >> "${LOGDIR}/out.log" 2> "${LOGDIR}/err.log"; then
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

      echo
      echo
      printf '=%.0s' {1..80}
      echo
    done
  done
done
echo


#
# FCCAnalyses tests
#
declare -a FCCANATESTS=(
  fccanalyses/fccanalysis-build
  fccanalyses/fccanalysis-stack-help
  fccanalyses/fccanalysis-stack-run
  fccanalyses/fccanalysis-stack-full-analysis
  fccanalyses/fccanalysis-calo-ntupleizer
)

for STACK in "${!STACKS[@]}"; do
  export FCCTESTS_STACK=${STACKS[$STACK]}

  for TEST in "${FCCANATESTS[@]}"; do
    LOGDIR="${LOGDIR_STEM}/${TEST}/${STACK}"
    mkdir -p "${LOGDIR}"

    echo $(date) > "${LOGDIR}/out.log"

    if ! bash "${WORKDIR}/${TEST}.sh" >> "${LOGDIR}/out.log" 2> "${LOGDIR}/err.log"; then
      NFAILURES=$((NFAILURES+1))

      echo -e "\n[FAILURE]  ${TEST}" | tee -a ${SUMMARYFILE} 1>&2
      echo "    Stack:  ${STACK}" | tee -a ${SUMMARYFILE} 1>&2
    else
      echo -e "\n[SUCCESS]  ${TEST}" | tee -a ${SUMMARYFILE} 1>&2
      echo "    Stack:  ${STACK}" | tee -a ${SUMMARYFILE} 1>&2
    fi

    echo $(date) >> "${LOGDIR}/out.log"

    echo
    echo
    printf '=%.0s' {1..80}
    echo
  done
done


#
# k4RecCalorimeter tests
#
declare -a K4RECCALOTESTS=(
  k4reccalo/k4reccalo-build
)

for STACK in "${!STACKS[@]}"; do
  export FCCTESTS_STACK=${STACKS[$STACK]}

  for TEST in "${K4RECCALOTESTS[@]}"; do
    LOGDIR="${LOGDIR_STEM}/${TEST}/${STACK}"
    mkdir -p "${LOGDIR}"

    echo $(date) > "${LOGDIR}/out.log"

    if ! bash "${WORKDIR}/${TEST}.sh" >> "${LOGDIR}/out.log" 2> "${LOGDIR}/err.log"; then
      NFAILURES=$((NFAILURES+1))

      echo -e "\n[FAILURE]  ${TEST}" | tee -a ${SUMMARYFILE} 1>&2
      echo "    Stack:  ${STACK}" | tee -a ${SUMMARYFILE} 1>&2
    else
      echo -e "\n[SUCCESS]  ${TEST}" | tee -a ${SUMMARYFILE} 1>&2
      echo "    Stack:  ${STACK}" | tee -a ${SUMMARYFILE} 1>&2
    fi

    echo $(date) >> "${LOGDIR}/out.log"

    echo
    echo
    printf '=%.0s' {1..80}
    echo
  done
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
