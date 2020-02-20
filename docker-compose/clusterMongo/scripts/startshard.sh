#!/bin/bash
. /scripts/functions.sh

LOAD='loads'
EXECUTION='executions'

EXIST_DB=`echo "show dbs" | runsh mongo --auth | grep ${DATABASE_NAME} | wc -l`

EXIST_COLLECTIONS=`echo "db.getCollectionNames()" | runsh mongo --auth ${DATABASE_NAME}  | grep -E "${LOAD}|${EXECUTION}" | wc -l`


echo ">> Starting Shard"
echo ">>> EXIST_DB: ${EXIST_DB}"
echo ">>> EXIST_COLLECTIONS: ${EXIST_COLLECTIONS}"

# TO DO backup and restore faster way
echo ">>> Verifying if shard was made before"
if [ ${EXIST_COLLECTIONS} -eq 0 -a ${EXIST_DB} -eq 0 ]
then
  echo ">>>> Setting shards"
  echo ">>>> Creating and Enabling sharding for database ${DATABASE_NAME}"
  echo "use ${DATABASE_NAME}" | runsh mongo --auth -u ${ROOT}
  echo "sh.enableSharding('${DATABASE_NAME}')" | runsh mongo --auth -u ${ROOT}

  echo ">>>> Creating and sharding collections ${DATABASE_NAME}.${LOAD}"
  echo "db.createCollection(\"${DATABASE_NAME}.${LOAD}\")" | runsh mongo --auth -u ${ROOT}
  echo "sh.shardCollection(\"${DATABASE_NAME}.${LOAD}\", { id_files_rows: 1 })" | runsh mongo --auth -u ${ROOT}

  echo ">>>> Creating and sharding collections ${DATABASE_NAME}.${EXECUTION}"
  echo "db.createCollection(\"${DATABASE_NAME}.${EXECUTION}\")" | runsh mongo --auth -u ${ROOT}
  echo "sh.shardCollection(\"${DATABASE_NAME}.${EXECUTION}\", { id_client: 1 })" | runsh mongo --auth -u ${ROOT}
else
  echo ">>>> Setted shard Before"
fi
