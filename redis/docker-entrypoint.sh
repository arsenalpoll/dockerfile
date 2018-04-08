#!/bin/bash
set -e

if [ "$REDIS_PASSWORD" == "Sunyard88" ]
then
	sed -i 's/Sunyard88/'"$REDIS_PASSWORD"'/g' /usr/local/etc/redis/redis.conf
else
	sed -i 's/Sunyard88/'"$REDIS_PASSWORD"'/g' /usr/local/etc/redis/redis.conf
	sed -i 's/Sunyard88/'"$REDIS_PASSWORD"'/g' /usr/bin/redis-trib
fi

# replace redis password

if [  "$REDIS_PORT" == "6379" ]
then
	sed -i 's/port\ 6379/'"port\ $REDIS_PORT"'/g' /usr/local/etc/redis/redis.conf
else
	sed -i 's/port\ 6379/'"port\ $REDIS_PORT"'/g' /usr/local/etc/redis/redis.conf
fi


if [ "$REDIS_CLUSTER" == "no" ] 
then
	sed -i  's/cluster\-enabled\ no/'"cluster\-enabled\ $REDIS_CLUSTER"'/g'  /usr/local/etc/redis/redis.conf
else
	sed -i  's/cluster\-enabled\ no/'"cluster\-enabled\ $REDIS_CLUSTER"'/g'  /usr/local/etc/redis/redis.conf

fi

#mkdir -p /data/redis/data /data/redis/log
mkdir -p /data/redis/data
chown -R redis:redis /usr/local/etc /data 

# first arg is `-f` or `--some-option`
# or first arg is `something.conf`
if [ "${1#-}" != "$1" ] || [ "${1%.conf}" != "$1" ]; then
	set -- redis-server "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'redis-server' -a "$(id -u)" = '0' ]; then
	chown -R redis .
	exec gosu redis "$0" "$@"
fi

exec "$@"
