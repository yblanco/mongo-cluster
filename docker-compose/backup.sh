#!/bin/bash
# Deprecated [No used]
COUNT_LOADS=$1
COUNT_EXECUTIONS=$2

if [ -z ${BACKUP_PATH} ]
then
  echo "Restore no enabled"
else
  if [ ${COUNT_LOADS} -eq 0 -a ${COUNT_EXECUTIONS} -eq 0 ]
  then
    EXIST_BACKUP=`ls ${BACKUP_PATH} | wc -l`
    if [ ${EXIST_BACKUP} -eq 0 ]
    then
      echo "Backup Data does not exist"
    else
      echo "Starting Mongorestore"
      echo "  Path: ${BACKUP_PATH}"
      mongorestore ${BACKUP_PATH}
    fi
  else
    echo "Data restored before"
  fi
fi
