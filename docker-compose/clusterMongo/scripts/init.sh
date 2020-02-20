#!/bin/bash
. /scripts/functions.sh

if [ -z ${FIRST} ]
then
  if [ ${TYPE_NODE} = "route" ]
  then
    export FIRST="yes"
  else
    export FIRST="no"
  fi
fi

echo "Starting Node for ${TYPE_NODE} server. Principal: ${FIRST}"
echo "Mongo Version: ${MONGO_VERSION}"

export AUTH_DB="admin"
export DATABASE_NAME="management"
export ROOT="root"
export KEY_FILE_PATH="/keyfile"
export LOG_PATH="/var/log/mongodb.log"

echo "> Checking KeyFile ${KEY_FILE_PATH}"
if [ -f ${KEY_FILE_PATH} ];
then
  case "${TYPE_NODE}" in
    "config")
      echo "> Config Node"
      runmongod configsvr
      callsettingnode replicaset true
      break
      ;;
  	"shard")
      echo "> Shard Node"
  		runmongod shardsvr
      callsettingnode replicaset false
  		break
  		;;
    "route")
      echo "> Route Node"
      runmongos
      echo "Wait for reach the config servers"
      wait $((SHARDS_CANT * 10))
      runsh createusers
      callsettingnode route false true
      runsh startshard
      break
      ;;
  	*)
  		echo "Node type undefined"
      exit 0
  		;;
  esac
  tail -f ${LOG_PATH}
else
  echo "ERROR: Key file doesnt exist"
  echo "Please create a key file and sure the volume is mounted in /keyfile"
  echo "  docker-compose has mounted the path ({PATH_TO_FILE}) /mnt/keyfile/mongo-keyfile for the keyfile"
  echo "  You can generate a keyfile using any method you choose. For example, openssl"
  echo "    openssl rand -base64 756 > {PATH_TO_FILE} && chmod 400 {PATH_TO_FILE}"
  echo "  For aditional details see https://docs.mongodb.com/manual/core/security-internal-authentication/#internal-auth-keyfile"
  exit 1
fi
