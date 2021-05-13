# Arancino Ecosystem for Docker
collection of Dockerfile(s) and docker-compose YAML files to easily run the ArancinoOS stack

docker: https://docs.docker.com/
docker-compose : https://docs.docker.com/compose/

## How to run

* Install docker on your system as described [here](https://docs.docker.com/get-docker/)
* Install docker-compose on your system as described [here](https://docs.docker.com/compose/install/)
* `cd` into the root folder of this project
* and then run:
```bash
docker-compose up -d
```
to build-up the container stack based on Debian Buster.

* instead run:
```bash
docker-compose -f docker-compose-alpine.yml up -d
```

to build-up the container stack based on Alpine Linux.

Once the command has been fired-up, docker-compose itself will take care of building the layer images and running a set of isolated containers in a standard docker network. In the very specific, the running containers will be:

* **redis-volatile** (volatile instance of Redis running on port 6379)
* **redis-persistent** (persistent instance of Redis running on port 6380)
* **rediseen-volatile** (REST-like API service for Redis volatile database running on port 8000)
* **rediseen-persistent** (REST-like API service for Redis persistent database running on port 8001)
* **lrod** (instance of Lightning-rod python module running on port 1474)
* **arancino** (instance of arancino python module running on port 1475)

to be sure that the containers are properly up and running, execute from bash:

```bash
docker ps -a
```

and, in case, look for errors checking out the container internal logs with:

```bash
docker logs -f <CONTAINER_NAME>
```

At this point, you should be to attach you Arancino device (i.e. Arancino Mignon) to your desktop system and interact with the Arancino module itself, since the serial device is mapped inside the `arancino` container itself.

So, enter the container with:

```bash
docker exec -ti arancino bash
```

and check the running arancino log with:

```bash
tail -f /var/log/arancino/arancino.log
```

what we expect, of course, is to get the MCU firmware interacting with the python module as it should on a physical Arancino main board.
