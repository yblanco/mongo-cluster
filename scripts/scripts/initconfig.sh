CONFIG=($@)

CONFIGNODES=""
for index in ${!CONFIG[*]}
do
  DOCKER=${CONFIG[index]}
  CONFIGNODES="${CONFIGNODES} { _id: ${index}, host : \"${DOCKER}:27017\" }"
  if [ $((${index}+1)) -lt  ${#CONFIG[@]} ]
  then
    CONFIGNODES="${CONFIGNODES},"
  fi
done

echo "rs.initiate(
  {
    _id: \"${REPLSET}\",
    configsvr: true,
    version: 1,
    members: [ $CONFIGNODES ]
  }
)" > /init.js

chmod 777 /init.js
