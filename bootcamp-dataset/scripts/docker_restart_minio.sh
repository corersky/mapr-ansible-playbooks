#! /bin/bash

# re-launch minio docker

# Get the MapR Cluster name
MAPR_CLUSTER_NAME=`head -n 1 /opt/mapr/conf/mapr-clusters.conf | awk '{print $1}'`

# Get the CLDB hostname
MAPR_CLDB_HOST_NAME=`head -n 1 /opt/mapr/conf/mapr-clusters.conf | awk '{print $3}'`
MAPR_CLDB_HOST_NAME=${MAPR_CLDB_HOST_NAME%:7222}

# Get the mapr uid and gid
MAPR_UID=`id -u mapr`
MAPR_GID=`id -g mapr`


# Kill minio docker if currently running
docker ps | awk '{ print $1,$2 }' | grep mapr-pacc-minio-docker | awk '{print $1 }' | xargs -I {} docker kill {}


# Launch the docker container
docker run -d \
--cap-add SYS_ADMIN \
--cap-add SYS_RESOURCE \
--device /dev/fuse \
--restart=always \
-e MAPR_CLUSTER=$MAPR_CLUSTER_NAME \
-e MAPR_CLDB_HOSTS=$MAPR_CLDB_HOST_NAME \
-e MAPR_CONTAINER_USER=mapr \
-e MAPR_CONTAINER_GROUP=mapr \
-e MAPR_CONTAINER_UID=$MAPR_UID \
-e MAPR_CONTAINER_GID=$MAPR_GID \
-e MAPR_MOUNT_PATH=/mapr \
-e MINIO_PATH=/mapr/$MAPR_CLUSTER_NAME/minio \
-e MINIO_ACCESS_KEY=maprbootcamp \
-e MINIO_SECRET_KEY=maprbootcamp \
-p 8080:9000 \
mkieboom/mapr-pacc-minio-docker
