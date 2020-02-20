#!/bin/bash
. /scripts/functions.sh
if [  ${FIRST} = "yes" ]
then
  echo ">> Run admin user creation in authenticationDatabase: ${AUTH_DB}"
  EXIST_ADMIN=`echo "db.getSiblingDB('${AUTH_DB}').system.users.find()" | runsh mongo --auth -u ${ROOT} | grep "${AUTH_DB}.${ROOT}"  | wc -l`
  if [ ${EXIST_ADMIN} -eq 0 ]
  then
    echo ">>> SERVER TYPE: ${TYPE_NODE}"
    echo ">>> Creating user ${ROOT}:"
    echo "db.getSiblingDB('${AUTH_DB}').createUser({ user: '${ROOT}', pwd: '${MONGO_INITDB_ROOT_PASSWORD}', roles: [ { role: 'root', db: '${AUTH_DB}' } ]})" | runsh mongo
    echo ">>> User ${ROOT} created";
  else
    echo ">>> User root was created before"
  fi
  if [  ${TYPE_NODE} = "route" ]
  then
    EXIST_USER=`echo "db.getSiblingDB('${AUTH_DB}').system.users.find()" | runsh mongo --auth -u ${ROOT} | grep "${AUTH_DB}.${MONGO_INITDB_ROOT_USERNAME}" | wc -l`;
    if [ ${EXIST_USER} -eq 0 ]
    then
      echo ">>> Creating user ${MONGO_INITDB_ROOT_USERNAME} with role readWrite in database ${DATABASE_NAME}"
      echo "db.getSiblingDB('${AUTH_DB}').createUser({ user: '${MONGO_INITDB_ROOT_USERNAME}', pwd: '${MONGO_INITDB_ROOT_PASSWORD}', roles: [ { role: 'readWrite', db: '${DATABASE_NAME}' } ]})" | runsh mongo --auth -u ${ROOT}
      echo ">>> User ${MONGO_INITDB_ROOT_USERNAME} created"
    else
      echo ">>> User ${MONGO_INITDB_ROOT_USERNAME} was created before or password invalid"
    fi
  fi
  echo ">> User creation Finished"
else
  echo ">> Not necessary create User in this node"
fi
