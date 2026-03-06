#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

#
# Global setup
#
export FCCTESTS_SCRIPTPATH=$(realpath "$0")
export FCCTESTS_DIR=$(dirname "${FCCTESTS_SCRIPTPATH}")
export FCCTESTS_TMPDIR=/tmp/fcc-tests

FCCTESTS_NTHREADS="$(nproc)"
if [ "${FCCTESTS_NTHREADS}" -gt "16" ]; then
  FCCTESTS_NTHREADS="16"
fi
export FCCTESTS_NTHREADS

LOGDIR_STEM="${FCCTESTS_TMPDIR}/log"
SUMMARYFILE="${FCCTESTS_TMPDIR}/fcc-test-summary.txt"
MAILFILE="${FCCTESTS_TMPDIR}/fcc-test-mail.txt"

mkdir -p ${FCCTESTS_TMPDIR}
MAILLISTFILE=${FCCTESTS_DIR}/emails.lst
RUNDATE=$(date)
NFAILURES=0

# Load utility functions
source ${SCRIPT_DIR}/utils.sh

#
# Run tests
#

: > ${SUMMARYFILE}  # Clearing summary file
rm -rf ${FCCTESTS_TMPDIR}
mkdir -p "${FCCTESTS_TMPDIR}"


declare -A STACKS=(
  ["release"]="/cvmfs/sw.hsf.org/key4hep/setup.sh"
  ["nightlies"]="/cvmfs/sw-nightlies.hsf.org/key4hep/setup.sh"
)

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
# TODO: Convert to HTML email
for TEST in "${EDM4HEPTESTS[@]}"; do
  for STACK in "${!STACKS[@]}"; do
    export FCCTESTS_STACK=${STACKS[$STACK]}

    for INFILE in "${!EDM4HEPINFILES[@]}"; do
      export FCCTESTS_INFILE=${EDM4HEPINFILES[$INFILE]}

      LOGDIR="${LOGDIR_STEM}/${TEST}/${STACK}/${INFILE}"
      mkdir -p "${LOGDIR}"

      echo -e "$(date)\n" > "${LOGDIR}/out.log"
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

      echo -e "\n$(date)" >> "${LOGDIR}/out.log"
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
  fccanalyses/fccanalysis-build-calo-ntupleizer
  fccanalyses/fccanalysis-stack-help
  fccanalyses/fccanalysis-stack-run
  fccanalyses/fccanalysis-stack-full-analysis
  fccanalyses/fccanalysis-stack-full-analysis-old-anascripts
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

    echo -e "$(date)\n" > "${LOGDIR}/out.log"

    if ! bash "${FCCTESTS_DIR}/${TEST}.sh" >> "${LOGDIR}/out.log" 2> "${LOGDIR}/err.log"; then
      NFAILURES=$((NFAILURES+1))

      echo -e "\n[FAILURE]  ${TEST}"

      {
        echo "<div>"
        echo "<p><span class=\"err\">FAILURE</span> ${TEST}</p>"
      } >> ${SUMMARYFILE}
    else
      echo -e "\n[SUCCESS]  ${TEST}"

      {
        echo "<div>"
        echo "<p><span class=\"ok\">SUCCESS</span> ${TEST}</p>"
      } >> ${SUMMARYFILE}
    fi

    echo "           Stack:      ${STACK}"
    echo "           Reference:  ${FCCTESTS_RNDMSTR}"
    {
      echo "<ul>"
      echo "<li>Stack: ${STACK}</li>"
      echo "<li>Reference: ${FCCTESTS_RNDMSTR}</li>"
      echo "</ul>"
      echo "</div>"
    } >> ${SUMMARYFILE}

    echo -e "\n$(date)" >> "${LOGDIR}/out.log"
  done

  echo "---"

  echo "<hr>" >> ${SUMMARYFILE}
done


#
# Send email(s)
#

SUBJECT="FCC Tests at $(hostname): ${NFAILURES} failures"
if [ "${NFAILURES}" -eq "0" ]; then
  SUBJECT="FCC Tests at $(hostname): All tests succeeded"
fi

{
  # Non existent accounts should use "-noreply" in the name
  echo "From: FCCTests <fcctests-noreply@cern.ch>"
  # TODO: Create a service account for receiving test results
  echo "To: $(get_email_recipients)"
  echo "Subject: ${SUBJECT}"
  echo "Content-Type: text/html"
  echo "MIME-Version: 1.0"
  echo ""

  echo "<!DOCTYPE html>"
  echo "<html>"
  echo "<head>"
  echo "<title>${SUBJECT}</title>"
  echo "<style>"
  echo ".err {color:white;"
  echo "      background-color:Tomato;"
  echo "      padding-left:5;"
  echo "      padding-right:5;"
  echo "      padding-top:0;"
  echo "      padding-bottom:2;"
  echo "      border-radius:3px;"
  echo "      margin-right:30;}"
  echo ".ok {color:white;"
  echo "     background-color:MediumSeaGreen;"
  echo "     padding-left:5;"
  echo "     padding-right:5;"
  echo "     padding-top:0;"
  echo "     padding-bottom:2;"
  echo "     border-radius:3px;"
  echo "     margin-right:20;}"
  echo "code {color: white;"
  echo "      background-color: Silver;"
  echo "      padding-left:5;"
  echo "      padding-right:5;"
  echo "      padding-top:0;"
  echo "      padding-bottom:2;"
  echo "      border-radius:3px;"
  echo "      white-space: nowrap;}"
  echo "</style>"
  echo "</head>"
  echo "<body>"
  echo "<p>Hi,<br>"
  echo "the tests run at $(hostname) on ${RUNDATE} and there were ${NFAILURES} failures.</p>"
  echo "<p>The Key4hep stacks used are as follows:</p>"
  echo "<ul>"
  for STACK in "${!STACKS[@]}"; do
    STACK_PATH=${STACKS[$STACK]}
    echo "  <li>${STACK}:"
    echo "    <ul>"
    echo "      <li>"
    echo "        <code>$(source $STACK_PATH > /dev/null;echo $KEY4HEP_STACK)</code>"
    echo "      </li>"
    echo "    </ul>"
    echo "  </li>"
  done
  echo "</ul>"
  echo "<p>The tests run in ${FCCTESTS_NTHREADS} threads</p>"

  cat ${SUMMARYFILE}

  echo "</body>"
  echo "</html>"
} > ${MAILFILE}

echo "Sending email..."

/usr/sbin/sendmail -t < ${MAILFILE}
