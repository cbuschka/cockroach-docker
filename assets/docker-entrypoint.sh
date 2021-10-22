#!/bin/bash

set -eu

if [ -z "${COCKROACH_LISTEN_ADDR}" ]; then
  COCKROACH_LISTEN_ADDR="0.0.0.0:26257"
fi
if [ -z "${COCKROACH_ADVERTISE_ADDR}" ]; then
  COCKROACH_ADVERTISE_ADDR="$(hostname -f):26257"
fi

if [ -z "${COCKROACH_HTTP_ADDR}" ] && [ "${COCKROACH_SECURITY_MODE}" = "insecure" ]; then
  COCKROACH_HTTP_ADDR=0.0.0.0:8080
elif [ -z "${COCKROACH_HTTP_ADDR}" ] && [ "${COCKROACH_SECURITY_MODE}" = "secure" ]; then
  COCKROACH_HTTP_ADDR=0.0.0.0:8443
fi

COCKROACH_SECURITY_OPTS=""
COCKROACH_SECURITY_START_OPTS=""
if [ "${COCKROACH_SECURITY_MODE}" = "insecure" ]; then
  COCKROACH_SECURITY_OPTS="--insecure"
  COCKROACH_SECURITY_START_OPTS="--insecure --accept-sql-without-tls"
elif [ "${COCKROACH_SECURITY_MODE}" = "secure" ]; then
  COCKROACH_SECURITY_OPTS="--certs-dir=${COCKROACH_CERTS_DIR}"
  COCKROACH_SECURITY_START_OPTS="--certs-dir=${COCKROACH_CERTS_DIR} --listen-addr=${COCKROACH_LISTEN_ADDR} --advertise-addr=${COCKROACH_ADVERTISE_ADDR} --http-addr=${COCKROACH_HTTP_ADDR}"
else
  echo "COCKROACH_SECURITY must be secure or insecure."
  exit 1
fi

if [ "${COCKROACH_SECURITY_MODE}" != "insecure" ]; then
  if [ ! -f "${COCKROACH_CERTS_DIR}/ca.key" ]; then
    echo "Generating ca.key..."
    /cockroach/cockroach cert create-ca --ca-key=${COCKROACH_CERTS_DIR}/ca.key
  else
    echo "ca.key already exists."
  fi

  if [ ! -f "${COCKROACH_CERTS_DIR}/node.crt" ]; then
    echo "Generating node.crt..."
    /cockroach/cockroach cert create-node --ca-key=${COCKROACH_CERTS_DIR}/ca.key roach1 localhost $(hostname)
  else
    echo "node.crt already exists."
  fi

  if [ ! -f "${COCKROACH_CERTS_DIR}/client.root.crt" ]; then
    echo "Generating root client certificate..."
    /cockroach/cockroach cert create-client root --ca-key=${COCKROACH_CERTS_DIR}/ca.key
  else
    echo "client.root.crt already exists."
  fi
fi

if [ $# -eq 0 ]; then
  /cockroach/cockroach start-single-node \
    ${COCKROACH_SECURITY_OPTS} ${COCKROACH_SECURITY_START_OPTS} \
    --pid-file=/run/cockroach.pid \
    --store=path=${COCKROACH_DATA_DIR} \
    --background ${COCKROACH_EXTRA_START_OPTS}
  COCKROACH_PID=$(cat /run/cockroach.pid)
  echo "PID is ${COCKROACH_PID}."

  echo "Waiting for cockroach to come up..."
  while ! /cockroach/cockroach sql ${COCKROACH_SECURITY_OPTS} --database defaultdb --user root -e "select 1" 1>/dev/null 2>&1; do
    sleep 1
  done
  echo "Good, cockroach is reachable."

  if [ ! -z "${COCKROACH_ROOT_PASSWORD}" ]; then
    echo "Changing password of root user..."
    echo "alter user root with password '${COCKROACH_ROOT_PASSWORD}';" | /cockroach/cockroach sql ${COCKROACH_SECURITY_OPTS} --database defaultdb --user root
  fi
  echo "grant admin to root;" | /cockroach/cockroach sql ${COCKROACH_SECURITY_OPTS} --database defaultdb --user root

  if [ ! -z "${COCKROACH_USER}" ] && [ ! -z "${COCKROACH_PASSWORD}" ] ; then
    if [ -z "${COCKROACH_PASSWORD}" ]; then
      echo "Creating user ${COCKROACH_USER} without password..."
      echo "create user ${COCKROACH_USER};" | /cockroach/cockroach sql ${COCKROACH_SECURITY_OPTS} --database defaultdb --user root
    else
      echo "Creating user ${COCKROACH_USER} with password..."
      echo "create user ${COCKROACH_USER} with password '${COCKROACH_PASSWORD}';" | /cockroach/cockroach sql ${COCKROACH_SECURITY_OPTS} --database defaultdb --user root
    fi
    echo "grant admin to ${COCKROACH_USER};" | /cockroach/cockroach sql ${COCKROACH_SECURITY_OPTS} --database defaultdb --user root
  fi

  if [ ! -z "${COCKROACH_DATABASE}" ] ; then
    echo "Creating database ${COCKROACH_DATABASE}..."
    echo "create database if not exists ${COCKROACH_DATABASE} encoding='utf-8';" | /cockroach/cockroach sql ${COCKROACH_SECURITY_OPTS} --database defaultdb --user root
  fi

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
      /cockroach/cockroach sql --echo-sql ${COCKROACH_SECURITY_OPTS} --user root <${SCRIPT}
      touch ${STAT_FILE}
    else
      echo -e "\nSkipping ${SCRIPT}."
    fi
  done
  echo

  echo "Cockroach is READY."

  tail --pid=${COCKROACH_PID} -f /dev/null
elif [ "${1-}" = "shell" ]; then
  shift
  exec /bin/sh "$@"
else
  exec /cockroach/cockroach "$@"
fi
