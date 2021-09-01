#!/bin/bash

set -o errexit

export MACHINE=${MACHINE:-raspberrypi3}

_ARCH=$(docker info | grep Architecture | awk '{ print $2 }')
ARCH=${ARCH:-$_ARCH}

VERSION=$(git describe --dirty --always)
REGISTRY=${REGISTRY:-docker.io}
REGISTRY_PATH=${REGISTRY_PATH:-igalia}
IMAGE=${IMAGE:-balena-wpe}
IMAGE_DOCKER="${REGISTRY}/${REGISTRY_PATH}/${IMAGE}:$MACHINE"

echo ">>> Importing docker image: $(ls -lh build/tmp/deploy/images/${MACHINE}/${IMAGE}-image-${MACHINE}.tar.gz)"
docker import - ${IMAGE_DOCKER} < build/tmp/deploy/images/${MACHINE}/${IMAGE}-image-${MACHINE}.tar.gz
docker tag "${IMAGE_DOCKER}" "${IMAGE_DOCKER}-${VERSION}"

echo
echo ">>> Imported Docker image:"
echo "    - Machine: ${MACHINE}"
echo "    - Platform: ${ARCH}"
echo "    - Image: ${IMAGE_DOCKER} (${IMAGE_DOCKER}-${VERSION})"

