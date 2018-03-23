#!/bin/bash 

# Use this only for running individual containers locally
# On cpouta use docker-compose

IMAGE_NAME="seco-wordpress"
CONTAINER_NAME="$IMAGE_NAME"
IP="172.30.23.11"
CONTAINER_PORT="80"
PORT="8080"
NETWORK="seco"
NETWORK_CIDR="172.30.20.0/22"
CONTAINER_USER="$UID"
MOUNT_TARGET_WP="/var/www/html/"
MYSQL_IP="172.30.23.12"
MYSQL_PASSWORD="dummypassword"
WP_HOME='http://localhost:8080'
WP_SITEURL='http://localhost:8080'


# DOCKER

# Create docker network if it does not exist
docker network inspect "$NETWORK" > /dev/null 2>&1
if [ $? != 0 ]; then
	set -x # print the next comand
	docker network create --subnet $NETWORK_CIDR $NETWORK
    { set +x; } 2> /dev/null
fi 

mkdir -p vol-wp
chmod ug+rwX vol-wp

#Run the container
set -x # print the next command
docker run -it --rm \
	-u $CONTAINER_USER \
	--name $CONTAINER_NAME \
	--network $NETWORK \
	--ip $IP \
	--publish $PORT:$CONTAINER_PORT \
	--expose $CONTAINER_PORT \
    --mount "type=bind,source=$(pwd)/vol-wp/,target=$MOUNT_TARGET_WP" \
    -e "WP_DB_HOST=172.30.23.12" \
    -e "WP_DB_PASSWORD=$MYSQL_PASSWORD" \
    -e "WP_HOME=$WP_HOME" \
    -e "WP_SITEURL=$WP_SITEURL" \
	$IMAGE_NAME	
{ set +x; } 2> /dev/null
