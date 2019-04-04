# Docker Redis + Sentinel

The project define a deployment way of a redis + sentinel instance on a server

## Getting started

This permit to deploy via a docker-compose a redis with a sentinel instance in a master or slave way.
This is organized more on a server per server deployment for managing the HA and the failover.
So it permits to deploy at least on redis + sentinel instance for a master server and on an other server a slave instance, it's recommanded to have a second slave instance deployed on a third server.

### Prerequisites

`git`, `docker` and `docker-compose` should be installed.

Also this project provide an easy to use command tool from a `Makefile` (make or any equivalent is required)

#### Host system conf for performance

redis for better performance and to avoid WARN logs require some system configuration.  Here are logs shown at run :
```log
WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
```

With docker the following paramaters should be applied on the host and not on docker images:
```shell
sudo su -
touch /etc/rc.local
echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.local
echo 'echo never > /sys/kernel/mm/transparent_hugepage/defrag' >> /etc/rc.local
echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
```

To check that all properties are applied you should test theses commands:
```shell
sudo su -
sysctl net.core.somaxconn
# should return value to 0
sysctl vm.overcommit_memory
# should return value to 0
sysctl vm.nr_hugepages && grep -i HugePages_Total /proc/meminfo
# should return values to 0
# or
cat /sys/kernel/mm/transparent_hugepage/enabled
# where never should be selected
 ```

The following redis/sentinel WARN log
 ```log
 WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
 ```
 is fixed on Dockerfile.

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
* **MEMORY** - *Optional* - ***Default value is `64mb`*** - The memory size to fix for the redis server

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