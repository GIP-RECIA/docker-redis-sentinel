# Docker Redis + Sentinel

The project define a deployment way of a redis + sentinel instance on a server

## Getting started

This permit to deploy via a docker-compose a redis with a sentinel instance in a master or slave way.
This is organized more on a server per server deployment for managing the HA and the failover.
So it permits to deploy at least on redis + sentinel instance for a master server and on an other server a slave instance, it's recommanded to have a second slave instance deployed on a third server.

### Prerequisites

`git`, `docker` and `docker-compose` should be installed.

Also this project provide an easy to use command tool from a `Makefile` (make or any equivalent is required)

### Installing

```shell
git clone https://github.com/GIP-RECIA/docker-redis-sentinel.git
cd docker-redis-sentinel
```


### Configuring
The configuration need some properties to be set and that will be used on all services deplyed

```shell
make configure MASTER_DNS=yourhostname IS_MASTER=y ARGS...
```

#### Parameters to provide

* **MASTER_DNS** - *Mandatory* - The DNS hostname of the master server that will be resolved as an IP. Could be forced by setting the argument **MASTER** as an IP.
* **IS_MASTER** - *Mandatory* - ***possible values are `y` or `n`*** - Indicating if the instance will be a master or not.
* **MASTER_NAME** - *Optional* - ***Default value is `defaultmaster`*** - The redis cluster group name.
* **QUORUM** - *Optional* - ***Default value is `2`*** - The sentinel QUORUM property.
* **ANNOUNCE_IP** - *Optional* - The IP of instance that could be used by other redis + sentinel instance. A default value is resolved.

All these params will be saved in a .env file and a 'MODE' file (create a `SLAVE_CONF` or `MASTER_CONF` file) for the run needs, so you can modify all of these files.

### Running

```shell
# to start
make run
# to stop
make down
```

Also there is a possibility to run a whole 'cluster' for test purpose with
```shell
# to start
make test
# to stop
make down_test
```

Or all servers independently (in the same way) but you won't be able to run several instance at the same time without change on docker-compose files
```shell
make master
make slave
make down_master
make down slave
```