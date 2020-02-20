#!/bin/bash
SHARD=0
SCRIPT_NAME=$1
while [ ${SHARD} -lt ${SHARDS_CANT} ]
do
  SHARD=$((SHARD + 1))
  NODES=0
  while [ ${NODES} -lt ${SHARDS_REPLSET_CANT} ]
  do
    NODES=$((NODES + 1))
    SHARD_NAME="${REPLSET_NAME_SHARD}${SHARD}"
    DOCKER="${SHARD_NAME}${NODES}"
    echo "sh.addShard(\"${SHARD_NAME}/${DOCKER}:${PORT_MONGO}\")" >> ${SCRIPT_NAME}
  done
done
