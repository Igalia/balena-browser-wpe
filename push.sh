#!/bin/bash

set -o errexit

export MACHINE=${MACHINE:-raspberrypi3}

_ARCH=$(docker info | grep Architecture | awk '{ print $2 }')
ARCH=${ARCH:-$_ARCH}

VERSION=$(git describe --dirty --always)
REGISTRY=${REGISTRY:-docker.io}
REGISTRY_USER=${REGISTRY_USER:-user}
REGISTRY_PASSWORD=${REGISTRY_PASSWORD:-password}
REGISTRY_PATH=${REGISTRY_PATH:-igalia}
IMAGE=${IMAGE:-balena-wpe}
IMAGE_DOCKER="${REGISTRY}/${REGISTRY_PATH}/${IMAGE}:$MACHINE"

docker login -u ${REGISTRY_USER} -p ${REGISTRY_PASSWORD} ${REGISTRY}
docker push ${IMAGE_DOCKER}
docker push ${IMAGE_DOCKER}-${VERSION}

echo
echo ">>> Pushed docker image:"
echo "    - Registry: ${REGISTRY}"
echo "    - Machine: ${MACHINE}"
echo "    - Platform: ${ARCH}"
echo "    - Image: ${IMAGE_DOCKER} (${IMAGE_DOCKER}-${VERSION})"

