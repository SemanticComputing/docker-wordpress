#!/bin/bash 

# Use this only for running individual containers locally
# On cpouta use docker-compose

IMAGE="registry.access.redhat.com/openshift3/mysql-55-rhel7:latest"
CONTAINER_NAME="mysql"
IP="172.30.23.12"
CONTAINER_PORT="3306"
PORT="3306"
NETWORK="seco"
NETWORK_CIDR="172.30.20.0/22"
CONTAINER_USER="$UID"
MYSQL_PASSWORD="dummypassword"
MOUNT_TARGET_MYSQL="/var/lib/mysql/data"

# DOCKER

# Create docker network if it does not exist
docker network inspect "$NETWORK" > /dev/null 2>&1
if [ $? != 0 ]; then
	set -x # print the next comand
	docker network create --subnet $NETWORK_CIDR $NETWORK
    { set +x; } 2> /dev/null
fi 

mkdir vol-mysql-data
chmod -R ug-rwX vol-mysql-data

#Run the container
set -x # print the next command
docker run -it --rm \
	-u $CONTAINER_USER \
	--name $CONTAINER_NAME \
	--network $NETWORK \
	--ip $IP \
	--publish $PORT:$CONTAINER_PORT \
	--expose $CONTAINER_PORT \
    --mount "type=bind,source=$(pwd)/vol-mysql-data,target=$MOUNT_TARGET_MYSQL" \
    -e "MYSQL_ROOT_PASSWORD=$MYSQL_PASSWORD" \
	$IMAGE
{ set +x; } 2> /dev/null
