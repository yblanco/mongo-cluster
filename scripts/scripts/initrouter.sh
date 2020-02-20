CONFIG=($@)
echo "${CONFIG[@]}"

for index in ${!CONFIG[*]}
do
  CURRENT=${CONFIG[index]}
  SHARD=${CURRENT::(-1)}
  echo "sh.addShard(\"${SHARD}/${CURRENT}:27017\")" >> /init.js
done

chmod 777 /init.js
