#!/bin/bash

AUTH=0
USER="${MONGO_INITDB_ROOT_USERNAME}"
POSITIONAL=("--port" "${PORT_MONGO}")

while [[ $# -gt 0 ]]
do
  key="$1"
  shift
  case ${key} in
    -a|--auth)
      AUTH=1
      ;;
    -u|--user)
      USER=$1
      shift
      ;;
    *)
      POSITIONAL+=("$key")
      ;;
    esac
done


echo "***Connecting to Mongo***"
if [ ${AUTH} -eq 1 ]
then
  echo "- USER: ${USER}"
  echo "- AUTH_DB: ${AUTH_DB}"
  echo "- POSITIONAL: ${POSITIONAL[@]}"
  mongo -u ${USER} -p ${MONGO_INITDB_ROOT_PASSWORD} --authenticationDatabase ${AUTH_DB} ${POSITIONAL[@]}
else
  echo "- POSITIONAL: ${POSITIONAL[@]}"
  echo
  mongo ${POSITIONAL[@]}
fi
