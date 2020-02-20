Mongo Sharded Cluster with Docker Compose for production environment
====================================================================

### Mongo Components
* Config Server (3 member replica set): `mongoconfig1`,`mongoconfig1`,`mongoconfig1`
* 3 Shards (each a 3 member replica set):
	* `sa01`,`sa02`, `sa02`
	* `sb01`,`sb02`, `sb02`
	* `sc01`,`sc02`, `sc02`
* 1 Router: `mongos`

### Specifications:
* External access to router through port 27018
* DB data persistence using docker data volumes
* Setting DB and collections sharded


### References
https://www.simplilearn.com/replication-and-sharding-mongodb-tutorial-video		
https://dzone.com/articles/composing-a-sharded-mongodb-on-docker
https://www.sohamkamani.com/blog/2016/06/30/docker-mongo-replica-set/
