Mongo Sharded Cluster with Docker Compose
=========================================
A simple sharded Mongo Cluster with a replication factor of 2 running in `docker` using script.

### Mongo Components

* Config Server (3 member replica set): `config01`,`config02`,`config03`
* 3 Shards (each a 2 member replica set):
	* `shard01a`,`shard01b`
	* `shard02a`,`shard02b`
	* `shard03a`,`shard03b`
* 1 Router (mongos): `router`
* (TODO): DB data persistence using docker data volumes

### First Run (initial setup)
**Start all of the containers** (daemonized)

```
./run.sh build
```



## References:
https://github.com/chefsplate/mongo-shard-docker-compose
https://dzone.com/articles/composing-a-sharded-mongodb-on-docker
