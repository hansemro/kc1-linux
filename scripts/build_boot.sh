#!/usr/bin/env bash

# Build Android boot image (boot.img)
#
# Setup:
#   Create build directory inside Linux kernel
#       $ mkdir linux/build
#   Place this script to build directory
#       $ cp build_boot.sh linux/build
#
# Uses mkbootimg from Cyanogenmod:android_system_core/mkbootimg
# https://github.com/CyanogenMod/android_system_core.git
#
# Usage: ./build_boot.sh [OPTION]
#
# Available options:
#   help        : print help message
#   boot        : build and boot the image with fastboot
#   flash       : build and flash the image with fastboot
#   boot_prev   : just boot previously-built image with fastboot
#   flash_prev  : just flash previously-built image with fastboot
#

BUILD_TIME=`date +"%Y-%m-%d-%H-%M"`

build_boot_img() {
    cp ../arch/arm/boot/zImage ./$BUILD_TIME-zImage
    cp ../.config ./$BUILD_TIME-config
    cp ../arch/arm/boot/dts/omap4-kc1.dtb ./

    echo "Building $BUILD_TIME-boot.img"

    mkbootimg --kernel ./$BUILD_TIME-zImage --dt omap4-kc1.dtb \
        --pagesize 2048 --base 0x80000000 \
        --ramdisk_offset 0x01000000  --kernel_offset 0x00008000 \
        --second_offset 0x00f00000 --tags_offset 0x100 \
        --cmdline "newbootargs console=ttyO2,115200n8 \
        root=/dev/mmcblk0p9 mem=512M vram=24M omapfb.vram=0:8M \
        omapdss.def_disp=lcd2 omapdss.debug=y" -o $BUILD_TIME-boot.img

    echo "Successfully built $BUILD_TIME-boot.img"

    # Create link to the most recently created boot image
    echo "Linking $BUILD_TIME-boot.img as prev-boot.img"
    rm prev-boot.img
    ln -s $BUILD_TIME-boot.img prev-boot.img
}

if [ "$1" == "help" ]; then
    echo "./build_boot.sh               : build boot image with date and link" \
                                            "as prev-boot.img"
    echo "./build_boot.sh help          : print this help message and exit"
    echo "./build_boot.sh boot          : build boot image and boot with" \
                                            "fastboot"
    echo "./build_boot.sh just_boot     : just boot previously built image" \
                                            "with fastboot"
    echo "./build_boot.sh flash         : build boot image and flash boot" \
                                            "partition with fastboot"
    echo "./build_boot.sh just_flash    : just flash previously built image" \
                                            "with fastboot"
elif [ "$1" == "just_boot" ]; then
    echo "Booting prev-boot.img with fastboot"
    fastboot boot $BUILD_TIME-boot.img
elif [ "$1" == "just_flash" ]; then
    echo "Flashing prev-boot.img with fastboot"
    fastboot flash boot $BUILD_TIME-boot.img
else
    if ! [ -f ../arch/arm/boot/zImage ]; then
        echo "Error: missing zImage" >&2
    else
        build_boot_img
        if [ "$1" == "boot" ]; then
            echo "Booting $BUILD_TIME-boot.img with fastboot"
            fastboot boot $BUILD_TIME-boot.img
        elif [ "$1" == "flash" ]; then
            echo "Flashing $BUILD_TIME-boot.img with fastboot"
            fastboot flash boot $BUILD_TIME-boot.img
        fi
    fi
fi
