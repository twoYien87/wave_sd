#!/bin/bash

export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=toolchain/bin/arm-linux-gnueabihf-
make cyanogenmod_galaxysmtd_defconfig
make -j2
