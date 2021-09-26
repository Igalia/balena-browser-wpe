#!/bin/bash

set -o errexit

export IMAGE=${IMAGE:-wpe}
export MACHINE=${MACHINE:-raspberrypi3}
export BB_NUMBER_THREADS=${BB_NUMBER_THREADS:-16}
export PARALLEL_MAKE=${PARALLEL_MAKE:--j 30}
export TEMPLATECONF="../../yocto/conf/samples"

if [ "${SKIP_BUILD_YOCTO}" == "1" ]
then
    echo ">>> Create Yocto image (SKIPPED):"
else
    source sources/poky/oe-init-build-env build
    bitbake ${IMAGE}-image
    echo
    echo ">>> Created Yocto image:"
fi
echo "    - Image: ${IMAGE}-image"
echo "    - Machine: ${MACHINE}"

