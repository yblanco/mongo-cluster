#!/bin/bash
function stopDocker {
  DOCKERS=($@)
  for index in ${!DOCKERS[*]}
  do
    DOCKER=${DOCKERS[index]}

    if docker ps | grep -q ${DOCKER}
    then
      STOPPED="$(docker stop $DOCKER)";
    fi
    echo "      ${DOCKER} has been stopped"
  done
}


function wait {
  TIME=$1
  echo "      ${TIME}..."
  sleep 1
  if [ ${TIME} -gt 0 ]
  then
    wait $((TIME - 1))
  fi
}

function initiate {
  SCRIPT_NAME=$1
  DOCKER=$2
  SCRIPT_FULL_NAME="${SCRIPT_NAME}.sh"
  SCRIPT="scripts/${SCRIPT_FULL_NAME}"
  RS=(${@:3})
  echo "    Copying script '${SCRIPT}' for Replica Set ${RS[@]}"
  RUN="$(docker cp ${SCRIPT} ${DOCKER}:/init.sh)"
  echo "      Copied ${SCRIPT_FULL_NAME} into ${DOCKER}"
  echo "    Executing script ${SCRIPT_FULL_NAME}"
  RUN="$(docker exec -it ${DOCKER} bash -c 'chmod +x /init.sh')"
  RUN="$(docker exec -it ${DOCKER} bash ./init.sh ${RS[@]})"
  RUN="$(docker exec -it ${DOCKER} bash -c 'mongo --port 27017 < /init.js')"
  if echo "$RUN" | grep -q '"ok" : 1'
  then
    echo "      Replica Set created"
  else
    grep errmsg <<< "$RUN"
  fi
}



REBUILD="Yes"
IMAGE="mongo:4.0-xenial"
CONFIG=("config01" "config02" "config03")
SHARD1=("shard01a" "shard01b")
SHARD2=("shard02a" "shard02b")
SHARD3=("shard03a" "shard03b")
SHARDS=(${SHARD1[*]} ${SHARD2[*]} ${SHARD3[*]})
ROUTER="router"
NETWORK="mongo-cluster"

REPLSETS=("configserver" "shard01" "shard02" "shard03")
if [ -z $1 ]
then
  REBUILD="No"
fi



clear
echo " "
echo "Hi, welcome to the configuration for your new Mongo Sharded Cluster"
echo "  The cluster will have:"
echo "    - 3 Config Server"
echo "    - 3 Shard with 2 member replica set"
echo "    - 1 Router"
echo "Rebuild: $REBUILD"
echo " "

if [ -z $1  ]
then
  echo "Environment prepared"
  echo "Dockers runing"
else
echo "Preparing environment"
echo "  - Stoping containers"
stopDocker ${CONFIG[*]}
stopDocker ${SHARDS[*]}
stopDocker ${ROUTER}
echo "  - Cleaning orphans childs from docker"
CLEAN="$(docker system prune -f)"
echo "    - System pruned"
NETWORKPRUNE="$(docker network prune -f)"
echo "    - Network deleted"


echo "Building dockers for cluster"

echo "  - Creating network"
#NETWORKCRETED="$(docker network create --attachable	 ${NETWORK})"
NETWORKCRETED="$(docker network create ${NETWORK})"
echo "      ${NETWORK}: ${NETWORKCRETED}"

echo "  - Running config servers"
for index in ${!CONFIG[*]}
do
  DOCKER=${CONFIG[index]}
  RUN="$(docker run --expose=27017 --net=${NETWORK} --name ${DOCKER} -v /etc/localtime:/etc/localtime:ro -d -e SERVER=${DOCKER} -e REPLSET=${REPLSETS[0]} mongo:4.0-xenial mongod --port 27017 --configsvr --replSet ${REPLSETS[0]} --noprealloc --smallfiles --oplogSize 16)"
  echo "      ${DOCKER}: ${RUN}"
done

echo "  - Running Shards Replica Set"
echo "    Shard01:"
for index in ${!SHARD1[*]}
do
  DOCKER=${SHARD1[index]}
  RUN="$(docker run --expose=27017 --net=${NETWORK} --name ${DOCKER} -v /etc/localtime:/etc/localtime:ro -d -e SERVER=${DOCKER} -e REPLSET=${REPLSETS[1]} mongo:4.0-xenial mongod --port 27017 --shardsvr --replSet ${REPLSETS[1]} --noprealloc --smallfiles --oplogSize 16)"
  echo "      ${DOCKER}: ${RUN}"
done
echo "    Shard02:"
for index in ${!SHARD2[*]}
do
  DOCKER=${SHARD2[index]}
  RUN="$(docker run --expose=27017 --net=${NETWORK} --name ${DOCKER} -v /etc/localtime:/etc/localtime:ro -d -e SERVER=${DOCKER} -e REPLSET=${REPLSETS[2]} mongo:4.0-xenial mongod --port 27017 --shardsvr --replSet ${REPLSETS[2]} --noprealloc --smallfiles --oplogSize 16)"
  echo "      ${DOCKER}: ${RUN}"
done
echo "    Shard03:"
for index in ${!SHARD3[*]}
do
  DOCKER=${SHARD3[index]}
  RUN="$(docker run --expose=27017 --net=${NETWORK} --name ${DOCKER} -v /etc/localtime:/etc/localtime:ro -d -e SERVER=${DOCKER} -e REPLSET=${REPLSETS[3]} mongo:4.0-xenial mongod --port 27017 --shardsvr --replSet ${REPLSETS[3]} --noprealloc --smallfiles --oplogSize 16)"
  echo "      ${DOCKER}: ${RUN}"
done


echo "  - Running Route"
echo "    For run router should wait for the shards and config"
echo "    Wait for 5 seconds"
wait 5
CONFIGDB="${REPLSETS[0]}/"
for index in ${!CONFIG[*]}
do
  DOCKER=${CONFIG[index]}
  CONFIGDB="${CONFIGDB}${DOCKER}:27017"
  if [ $((${index}+1)) -lt  ${#CONFIG[@]} ]
  then
    CONFIGDB="${CONFIGDB},"
  fi
done
RUN="$(docker run --expose=27017 -p 27027:27017 --net=${NETWORK} --name ${ROUTER} -v /etc/localtime:/etc/localtime:ro -d mongo:4.0-xenial mongos --port 27017 --configdb ${CONFIGDB} --bind_ip_all)"
echo "    ${ROUTER}: ${RUN}"
fi

echo "Setting dockers started"
echo "  - Setting Config"
initiate initconfig ${CONFIG[0]} ${CONFIG[@]}
echo "  - Setting Shard ${REPLSETS[1]}"
initiate initshard ${SHARD1[0]} ${SHARD1[@]}
echo "  - Setting Shard ${REPLSETS[2]}":
initiate initshard ${SHARD2[0]} ${SHARD2[@]}
echo "  - Setting Shard ${REPLSETS[3]}":
initiate initshard ${SHARD3[0]} ${SHARD3[@]}

echo "  - Setting router"
echo "    For set router should wait for the shards and config"
echo "    Wait for 20 seconds"
wait 20

initiate initrouter ${ROUTER} ${SHARDS[@]}

echo "Cluster Created"
