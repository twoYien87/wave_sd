#!/bin/bash

export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=/home/demo/Vidéos/wave_sd/toolchain/bin/arm-linux-gnueabihf-
make cyanogenmod_galaxysmtd_defconfig
make -j2
