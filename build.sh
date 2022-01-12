#!/bin/sh

id=$(docker run -td --rm ubuntu)

docker cp . $id:i2p-zero

docker exec -ti $id bash -c  '\
  rm -rf import \
  && rm -rf dist-* \
  && apt-get update \
  && apt-get -y install git wget zip unzip \
  && cd i2p-zero \
  && bash bin/build-all-and-zip.sh'

docker cp $id:i2p-zero/dist-zip ./

docker container stop $id