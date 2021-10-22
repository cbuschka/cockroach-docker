#!/bin/bash

set -eu

if [ $# -eq 0 ]; then
  /cockroach/cockroach start-single-node \
    --store=path=/cockroach/cockroach-data \
    --insecure \
    --accept-sql-without-tls \
    --pid-file=/run/cockroach.pid \
    --background
  COCKROACH_PID=$(cat /run/cockroach.pid)
  echo "PID is ${COCKROACH_PID}."

  echo "Waiting for cockroach to come up..."
  while ! /cockroach/cockroach sql --insecure -e "select 1" 1>/dev/null 2>&1; do
    sleep 1
  done
  echo "Good, cockroach is reachable."

  STAT_DIR=/cockroach/cockroach-data/initdb.status
  mkdir -p ${STAT_DIR}
  for SCRIPT in /docker-entrypoint-initdb.d/*; do
    [ -f "${SCRIPT}" ] || continue
    STAT_FILE=${STAT_DIR}/$(basename ${SCRIPT}).done

    if [[ -f ${STAT_FILE} ]]; then
      echo -e "\n${SCRIPT} already run. Skipping."
    elif [[ "${SCRIPT}" =~ .+\.sh ]]; then
      echo -e "\nRunning ${SCRIPT}..."
      bash ${SCRIPT}
      touch ${STAT_FILE}
    elif [[ ! -f ${STAT_FILE} ]] && [[ "${SCRIPT}" =~ .+\.sql ]]; then
      echo -e "\nRunning ${SCRIPT}..."
      /cockroach/cockroach sql --echo-sql --insecure <${SCRIPT}
      touch ${STAT_FILE}
    else
      echo -e "\nSkipping ${SCRIPT}."
    fi
  done
  echo

  tail --pid=${COCKROACH_PID} -f /dev/null
elif [ "${1-}" = "shell" ]; then
  shift
  exec /bin/sh "$@"
else
  exec /cockroach/cockroach "$@"
fi
