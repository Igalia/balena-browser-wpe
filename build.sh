#!/bin/bash

set -o errexit

export IMAGE=${IMAGE:-browser-wpe}
export MACHINE=${MACHINE:-raspberrypi3}
export BB_NUMBER_THREADS=${BB_NUMBER_THREADS:-16}
export PARALLEL_MAKE=${PARALLEL_MAKE:--j 30}
export TEMPLATECONF="../../yocto/conf/samples"
export BITBAKE_LOCAL_CONF="/home/psaavedra/bitbake_local.conf"

if [ "${SKIP_BUILD_YOCTO}" == "1" ]
then
    echo ">>> Create Yocto image (SKIPPED):"
else
    source sources/poky/oe-init-build-env build
    if [ -z ${BITBAKE_LOCAL_CONF+x} ]
    then
        bitbake ${IMAGE}-image
    else
        bitbake --postread=${BITBAKE_LOCAL_CONF} ${IMAGE}-image
    fi
    echo
    echo ">>> Created Yocto image:"
fi
echo "    - Image: ${IMAGE}-image"
echo "    - Machine: ${MACHINE}"
echo "    - Manifest: build/tmp/deploy/images/${MACHINE}/${IMAGE}-image-${MACHINE}.manifest"
echo ""
cat tmp/deploy/images/${MACHINE}/${IMAGE}-image-${MACHINE}.manifest
