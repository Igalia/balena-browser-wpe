#!/bin/bash

set -o errexit

export MACHINE=${MACHINE:-raspberrypi3}

_IGALIA="igalia"

_ARCH=$(docker info | grep Architecture | awk '{ print $2 }')
ARCH=${ARCH:-$_ARCH}

_VERSION=$(git describe --dirty --always)
VERSION=${VERSION:-$_VERSION}

REGISTRY=${REGISTRY:-docker.io}
REGISTRY_USER=${REGISTRY_USER:-user}
REGISTRY_PASSWORD=${REGISTRY_PASSWORD:-password}
REGISTRY_PATH=${REGISTRY_PATH:-$_IGALIA}
IMAGE=${IMAGE:-browser-wpe}
IMAGE_BALENA_IN_DOCKER="${REGISTRY}/${REGISTRY_PATH}/balena-${IMAGE}:${MACHINE}"
IMAGE_YOCTO_IN_DOCKER="${REGISTRY}/${REGISTRY_PATH}/docker-${IMAGE}:${MACHINE}"
# Required because the Dockerfile.template is set to # igalia/${IMAGE}:${MACHINE}
IMAGE_YOCTO_LOCAL_IN_DOCKER="${_IGALIA}/balena-${IMAGE}:${MACHINE}"

if [ "${SKIP_IMPORT_YOCTO}" == "1" ]
then
    echo ">>> Import Yocto image in Docker (SKIPPED):"
else
    echo ">>> Importing Yocto image: $(ls -lh build/tmp/deploy/images/${MACHINE}/${IMAGE}-image-${MACHINE}.tar.gz)"
    docker import - "${IMAGE_YOCTO_IN_DOCKER}" < build/tmp/deploy/images/${MACHINE}/${IMAGE}-image-${MACHINE}.tar.gz
    docker tag "${IMAGE_YOCTO_IN_DOCKER}" "${IMAGE_YOCTO_IN_DOCKER}-${VERSION}"
    docker tag "${IMAGE_YOCTO_IN_DOCKER}" "${IMAGE_YOCTO_LOCAL_IN_DOCKER}"
    docker tag "${IMAGE_YOCTO_IN_DOCKER}" "${IMAGE_YOCTO_LOCAL_IN_DOCKER}-${VERSION}"
    echo
    echo ">>> Imported Yocto image in Docker:"
fi
echo "    - Machine: ${MACHINE}"
echo "    - Platform: ${ARCH}"
echo "    - Image: ${IMAGE_YOCTO_LOCAL_IN_DOCKER} (${IMAGE_YOCTO_LOCAL_IN_DOCKER}-${VERSION})"

if [ "${SKIP_BUILD_BALENA}" == "1" ]
then
    echo ">>> Build Balena image (SKIPPED):"
else
    cp build/tmp/deploy/images/${MACHINE}/${IMAGE}-image-${MACHINE}.manifest ./balena/image.manifest
    rm -rf build
    balena build . --deviceType ${MACHINE} --arch ${ARCH} ${BALENA_BUILD_EXTRA_ARGS}
    docker tag "docker-balena-wpe_wpe" "${IMAGE_BALENA_IN_DOCKER}"
    docker tag "docker-balena-wpe_wpe" "${IMAGE_BALENA_IN_DOCKER}-${VERSION}"
fi

if [ "${SKIP_PUSH_BALENA_IMAGE}" == "1" ]
then
    echo ">>> Push Balena Docker image (SKIPPED):"
else
    docker login -u ${REGISTRY_USER} -p ${REGISTRY_PASSWORD} ${REGISTRY}
    docker push ${IMAGE_BALENA_IN_DOCKER}
    docker push ${IMAGE_BALENA_IN_DOCKER}-${VERSION}
    echo ">>> Pushed Balena docker image:"
fi
echo "    - Registry: ${REGISTRY}"
echo "    - Machine: ${MACHINE}"
echo "    - Platform: ${ARCH}"
echo "    - Image: ${IMAGE_BALENA_IN_DOCKER} (${IMAGE_BALENA_IN_DOCKER}-${VERSION})"

