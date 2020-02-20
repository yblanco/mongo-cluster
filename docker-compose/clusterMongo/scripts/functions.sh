#!/bin/bash

wait() {
  TIME=$1
  echo "  ${TIME}..."
  sleep 1
  if [ ${TIME} -gt 0 ]
  then
    wait $((TIME - 1))
  fi
}

runmongod() {
  if [ -z $1 ]
  then
    echo "Arg Type Node is required"
    exit 0
  fi
  echo ">> Run mongod as $1 in replSet ${REPLSET_NAME}"
  mongod --port ${PORT_MONGO} --$1 --replSet ${REPLSET_NAME} --keyFile ${KEY_FILE_PATH} --logpath ${LOG_PATH} --bind_ip_all --fork
  echo ">> Started mongod"

}

runmongos() {
  CONFIGDB="${REPLSET_NAME_CONFIG}/"
  NODES=0
  while [ ${NODES} -lt ${CONFIG_REPLSET_CANT} ]
  do
    NODES=$((NODES + 1))
    DOCKER="${REPLSET_NAME_CONFIG}${NODES}"
    CONFIGDB="${CONFIGDB}${DOCKER}:${PORT_MONGO}"
    if [ ${NODES} -lt ${CONFIG_REPLSET_CANT}  ]
    then
      CONFIGDB="${CONFIGDB},"
    fi
  done
  echo ">> Running mongos using config: ${CONFIGDB}"
  mongos --port ${PORT_MONGO} --configdb ${CONFIGDB} --keyFile ${KEY_FILE_PATH} --logpath ${LOG_PATH} --bind_ip_all --fork
  echo ">> Started mongos"
}

runsh() {
  SCRIPT_NAME=$1
  shift
  SCRIPT="/scripts/${SCRIPT_NAME}.sh"
  echo ">>>> Running ${SCRIPT}"
  TO_RUN=".${SCRIPT} ${@}"
  .${TO_RUN}
}


generatingJs() {
  echo ">>> Generating ${2} from ${1}"
  runsh "$@"
  chmod 777 $2
}

callsettingnode() {
  echo ">> Running Setting for ${TYPE_NODE} server"
  SCRIPT_NAME=$1
  CONFIG=$2
  AUTH="${3:-false}"
  JS="init.js"
  if [  ${FIRST} = "yes" ]
  then
    generatingJs ${SCRIPT_NAME} ${JS} ${CONFIG}
    if [ ${AUTH} = "false" ]
    then
      runsh mongo < ${JS}
    else
      runsh mongo --auth -u ${ROOT} < ${JS}
    fi
  else
    echo ">>> Node ${TYPE_NODE} is ready"
  fi
  echo ">>> Finished Setting for ${TYPE_NODE} server"
}
