#!/bin/bash

set -o errexit

export MACHINE=${MACHINE:-raspberrypi3}
export BB_NUMBER_THREADS=${BB_NUMBER_THREADS:-16}
export PARALLEL_MAKE=${PARALLEL_MAKE:--j 30}

export IMAGE="balena-wpe"
export IMAGE_YOCTO="${IMAGE}-image"

export TEMPLATECONF="../../${IMAGE}/conf/samples"

source sources/poky/oe-init-build-env build
bitbake ${IMAGE_YOCTO}

echo
echo ">>> Created Yocto image:"
echo "    - Image: ${IMAGE_YOCTO}"
echo "    - Machine: ${MACHINE}"

