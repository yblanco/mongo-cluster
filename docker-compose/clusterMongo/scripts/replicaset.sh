#!/bin/bash
SCRIPT_NAME=$1
IS_CONFIG=$2

CONFIGSVR=""

echo ">> Setting config server for Replica Set ${REPLSET_NAME} using ${REPLSET_CANT} nodes"

NODES=0
CONFIGNODES=""
while [ ${NODES} -lt ${REPLSET_CANT} ]
do
  INDEX=${NODES}
  NODES=$((NODES + 1))
  DOCKER="${REPLSET_NAME}${NODES}"
  echo "${TYPE_NODE} server node for ${REPLSET_NAME}: ${DOCKER}:${PORT_MONGO}"
  CONFIGNODES="${CONFIGNODES} { _id: ${INDEX}, host : \"${DOCKER}:${PORT_MONGO}\" }"
  if [ ${NODES} -lt ${REPLSET_CANT}  ]
  then
    CONFIGNODES="${CONFIGNODES},"
  fi
done

echo ">> Creating ${SCRIPT_NAME}"
if [ ${IS_CONFIG} = "true" ]
then
  CONFIGSVR="configsvr: true,"
  echo ">>> CONFIGSVR: true"
fi
echo ">>> MEMBERS: ${CONFIGNODES}"

echo "rs.initiate(
  {
    _id: \"${REPLSET_NAME}\",
    ${CONFIGSVR}
    version: 1,
    members: [ $CONFIGNODES ]
  }
)" > ${SCRIPT_NAME}
echo ">> Created ${SCRIPT_NAME}"
