#!/bin/bash

echo "Test Script"

SERVER_IP="192.168.120.25"
DATABASE_NAME="management"

PATH_BACKUP="/backup/data"
LOAD='loads'
EXECUTION='executions'


EXIST_DB=`echo "show dbs" | mongo | grep ${DATABASE_NAME} | wc -l`

EXIST_COLLECTIONS=`mongo ${DATABASE_NAME} --eval "db.getCollectionNames()" | grep -E "${LOAD}|${EXECUTION}" | wc -l`

COUNT_LOADS=`mongo ${DATABASE_NAME}   --eval "db.${LOAD}.count()" | tail -1`

COUNT_EXECUTIONS=`mongo ${DATABASE_NAME}   --eval "db.${EXECUTION}.count()" | tail -1`


echo "EXIST_DB: ${EXIST_DB}"
echo "EXIST_COLLECTIONS: ${EXIST_COLLECTIONS}"
echo "COUNT_LOADS: ${COUNT_LOADS}"
echo "COUNT_EXECUTIONS: ${COUNT_EXECUTIONS}"



if [ ${COUNT_LOADS} -eq 0 -a ${COUNT_EXECUTIONS} -eq 0 -a ${EXIST_COLLECTIONS} -eq 0 -a ${EXIST_DB} -eq 0 ]
then
   echo "Setting shards"
   echo "sh.enableSharding('${DATABASE_NAME}')" | mongo
   echo "db.createCollection(\"${DATABASE_NAME}.${LOAD}\")" | mongo
   echo "sh.shardCollection(\"${DATABASE_NAME}.${LOAD}\", { id_files_rows: 1 })" | mongo
   echo "db.createCollection(\"${DATABASE_NAME}.executions\")" | mongo
   echo "sh.shardCollection(\"${DATABASE_NAME}.executions\", { id_client: 1 })" | mongo
   echo "Starting Mongodump"
   mongodump --host ${SERVER_IP} --port ${PORT_OLD} --db=${DATABASE_NAME} --out=${PATH_BACKUP}
   echo "Starting Mongorestore"
   mongorestore ${PATH_BACKUP}
elif [${COUNT_LOADS} -eq 0 -a ${COUNT_EXECUTIONS} -eq 0]
then
  echo "Starting Mongodump"
  mongodump --host ${SERVER_IP} --port ${PORT_OLD} --db=${DATABASE_NAME} --out=${PATH_BACKUP}
  echo "Starting Mongorestore"
  mongorestore ${PATH_BACKUP}
else
  echo "Setted shard Before"
fi
