#!/bin/bash

if [ "$ZOO_CLUSTER" == "yes" ]

then
export ZOOKEEPER_SERVERS=$1
export ZOOKEEPER_ID=$2
echo "$ZOOKEEPER_ID" | tee $dataDir/myid

ZOOKEEPER_CONFIG=
ZOOKEEPER_CONFIG="$ZOOKEEPER_CONFIG"$'\n'"tickTime=$tickTime"
ZOOKEEPER_CONFIG="$ZOOKEEPER_CONFIG"$'\n'"dataDir=$dataDir"
ZOOKEEPER_CONFIG="$ZOOKEEPER_CONFIG"$'\n'"clientPort=$clientPort"
ZOOKEEPER_CONFIG="$ZOOKEEPER_CONFIG"$'\n'"initLimit=$initLimit"
ZOOKEEPER_CONFIG="$ZOOKEEPER_CONFIG"$'\n'"syncLimit=$syncLimit"
ZOOKEEPER_CONFIG="$ZOOKEEPER_CONFIG"$'\n'"maxClientCnxns=$maxClientCnxns"
ZOOKEEPER_CONFIG="$ZOOKEEPER_CONFIG"$'\n'"autopurge.snapRetainCount=$snapRetainCount"
ZOOKEEPER_CONFIG="$ZOOKEEPER_CONFIG"$'\n'"autopurge.purgeInterval=$purgeInterval"

IFS=', ' read -r -a ZOOKEEPER_SERVERS_ARRAY <<< "$ZOOKEEPER_SERVERS"
export ZOOKEEPER_SERVERS_ARRAY=$ZOOKEEPER_SERVERS_ARRAY
for index in "${!ZOOKEEPER_SERVERS_ARRAY[@]}"
do
    ZKID=$(($index+1))
    ZKIP=${ZOOKEEPER_SERVERS_ARRAY[index]}
    if [ $ZKID == $ZOOKEEPER_ID ]
    then
        # if IP's are used instead of hostnames, every ZooKeeper host has to specify itself as follows
        ZKIP=0.0.0.0
    fi
    ZOOKEEPER_CONFIG="$ZOOKEEPER_CONFIG"$'\n'"server.$ZKID=$ZKIP:2888:3888"
done

echo "$ZOOKEEPER_CONFIG" | tee conf/zoo.cfg
chown -R zookeeper:zookeeper /var/lib/zookeeper

else

ZOOKEEPER_CONFIG=
ZOOKEEPER_CONFIG="$ZOOKEEPER_CONFIG"$'\n'"tickTime=$tickTime"
ZOOKEEPER_CONFIG="$ZOOKEEPER_CONFIG"$'\n'"dataDir=$dataDir"
ZOOKEEPER_CONFIG="$ZOOKEEPER_CONFIG"$'\n'"clientPort=$clientPort"
ZOOKEEPER_CONFIG="$ZOOKEEPER_CONFIG"$'\n'"initLimit=$initLimit"
ZOOKEEPER_CONFIG="$ZOOKEEPER_CONFIG"$'\n'"syncLimit=$syncLimit"
ZOOKEEPER_CONFIG="$ZOOKEEPER_CONFIG"$'\n'"maxClientCnxns=$maxClientCnxns"
ZOOKEEPER_CONFIG="$ZOOKEEPER_CONFIG"$'\n'"autopurge.snapRetainCount=$snapRetainCount"
ZOOKEEPER_CONFIG="$ZOOKEEPER_CONFIG"$'\n'"autopurge.purgeInterval=$purgeInterval"

echo "$ZOOKEEPER_CONFIG" | tee conf/zoo.cfg
chown -R zookeeper:zookeeper /var/lib/zookeeper
fi

# start the server:
su zookeeper -s /bin/bash  -c "/usr/share/zookeeper/bin/zkServer.sh start-foreground | tee /var/lib/zookeeper/zookeeper.out"
