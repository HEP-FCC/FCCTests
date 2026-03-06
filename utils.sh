#
# Set of useful functions for the tests.
#

function get_email_recipients() {
  if [ ! -f "${MAILLISTFILE}" ]; then
    echo "Can't find email list file: ${MAILLISTFILE}" | tee -a ${SUMMARYFILE} 1>&2
    exit 1
  fi

  readarray -t EMAILS < "${MAILLISTFILE}"

  if [ "${#EMAILS[@]}" -lt 1 ]; then
    echo "Email list file is probably empty!" | tee -a ${SUMMARYFILE} 1>&2
    exit 1
  fi

  # https://stackoverflow.com/questions/74147127/converting-bash-array-into-string-with-in-between
  EMAILS_STR=$(IFS=','; echo "${EMAILS[*]}")

  echo "${EMAILS_STR}"
}
