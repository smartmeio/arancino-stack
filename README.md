# Arancino Ecosystem for Docker
collection of Dockerfile(s) and docker-compose YAML files to easily run the ArancinoOS stack

docker: https://docs.docker.com/
docker-compose : https://docs.docker.com/compose/

## How to run

* Install docker on your system as described (min 20.10.x) [here](https://docs.docker.com/get-docker/)
* Install docker-compose on your system as described (min 2.5.x) [here](https://github.com/docker/compose/releases/tag/v2.5.0)
* `cd` into the root folder of this project
* create a .env file
```bash
cp env_template .env
```
* and then run:
```bash
docker-compose up -d
```
to build-up the container stack based on Alpine Linux.

* instead run:
```bash
docker-compose -f docker-compose-debian.yml up -d
```

to build-up the container stack based on Debian Buster.

Once the command has been fired-up, docker-compose itself will take care of building the layer images and running a set of isolated containers in a standard docker network. In the very specific, the running containers will be:

* **redis-volatile** (volatile instance of Redis)
* **redis-persistent** (persistent instance of Redis)
* **lrod** (instance of Lightning-rod python module)
* **arancino** (instance of arancino python module)
* **mosquitto** (instance of mosquitto)
* **nodered** (instance of nodered)

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

## Change the default ports
These are the default values:
  
|Service| Variable | Port  |
|-------|-------|---|
|lrod|LRPORT|1474|
|arancino api|ARPORT|1475|
|mosquitto default|MPORT|1883|
|secure mosquitto |MSPORT|8883|
|websocket mosquitto |MWSPORT|9001|
|nodered |REDPORT|1880|

edit the .env file if you need to change them.

## How to launch the stack

* Install docker on your system as described (min 20.10.x) [here](https://docs.docker.com/get-docker/)
* Install docker-compose on your system as described (min 2.5.x) [here](https://github.com/docker/compose/releases/tag/v2.5.0)
* `cd` into the root folder of this project
* and then run:
```bash
docker-compose up -d
```
to build-up the container stack based on Alpine Linux.

* instead run:
```bash
docker-compose -f docker-compose-debian.yml up -d
```
to build-up the container stack based on Debian Buster.

## How to launch the stack with building the docker layer images

* Install docker on your system as described (min 20.10.x) [here](https://docs.docker.com/get-docker/)
* Install docker-compose on your system as described (min 2.5.x) [here](https://github.com/docker/compose/releases/tag/v2.5.0)
* `cd` into the root folder of this project
* and then run:
```bash
docker-compose -f docker-compose-build.yml up -d
```
to build-up the container stack based on Alpine Linux.

* instead run:
```bash
docker-compose -f docker-compose-build-debian.yml up -d
```
to build-up the container stack based on Debian Buster.


## Final notes for Mac OSX

Please note that under OSX, due to the specific system design, all volumes starting with the prefix:

**/srv/**

should be pointing at:

**./srv/**

instead, since this given system folder is not part of the Apple unix filesystem.

So, before firing up the whole ecosystem, please rename accordingly the volume definition so they point to local folders residing inside the source code main folder instead.