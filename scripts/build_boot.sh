#!/usr/bin/env bash

# Maintained by Hansem Ro (hansemro@outlook.com)

LINUX_DIR=$PWD/..
BUILD_DIR=$PWD
BUILD_TIME=`date +"%Y-%m-%d-%H-%M"`

# Build Android boot image (boot.img)
#
# Setup:
#   Create build directory inside Linux kernel directory
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

CMDLINE="rootwait rw root=/dev/mmcblk0p9"

# build_boot_img: Build Android boot image with the following:
#                   - kernel (linux/arch/arm/boot/zImage)
#                   - device tree blob (linux/arch/arm/boot/dts/omap4-kc1.dtb)
#                   - offset parameters
#                   - cmdline
#
#                 The new boot image (along with the zImage, dtb, and config) will
#                 be located at build/<build_time>/boot.img.
#
#                 In addition, a link to the most recently-created image
#                 will be made (prev-boot.img).
build_boot_img() {
    mkdir -p build/$BUILD_TIME
    cd build/$BUILD_TIME
    cp $LINUX_DIR/arch/arm/boot/zImage ./zImage
    cp $LINUX_DIR/.config ./config
    cp $LINUX_DIR/arch/arm/boot/dts/omap4-kc1.dtb ./omap4-kc1.dtb

    echo "Building build/$BUILD_TIME/boot.img"

    mkbootimg --kernel ./zImage \
        --dt omap4-kc1.dtb \
        --pagesize 2048 --base 0x80000000 \
        --ramdisk_offset 0x01000000  --kernel_offset 0x00008000 \
        --second_offset 0x00f00000 --tags_offset 0x100 \
        --cmdline "$CMDLINE" -o boot.img

    # Create link to the most recently created boot image
    cd $BUILD_DIR
    echo "Linking build/$BUILD_TIME/boot.img as prev-boot.img"
    rm prev-boot.img
    ln -s build/$BUILD_TIME/boot.img prev-boot.img
}

# boot_target: Boot passed image with fastboot
#   @param 1 : boot image file
boot_target() {
    if [ -L $1 ]; then
        echo "Booting $(readlink $1) with fastboot"
        fastboot boot $1
    elif [ -f $1 ]; then
        echo "Booting $1 with fastboot"
        fastboot boot $1
    fi
}

# flash_target: Flash passed image with fastboot
#   @param 1 : boot image file
flash_target() {
    if [ -L $1 ]; then
        echo "Flashing $(readlink $1) with fastboot"
        fastboot flash boot $1
    elif [ -f $1 ]; then
        echo "Flashing $1 with fastboot"
        fastboot flash boot $1
    fi
}

if [ "$1" == "help" ]; then
    echo "./build_boot.sh            : build boot image with date and link" \
                                            "as prev-boot.img"
    echo "./build_boot.sh help       : print this help message and exit"
    echo "./build_boot.sh boot       : build boot image and boot with" \
                                            "fastboot"
    echo "./build_boot.sh boot_prev  : just boot previously built image" \
                                            "with fastboot"
    echo "./build_boot.sh flash      : build boot image and flash boot" \
                                            "partition with fastboot"
    echo "./build_boot.sh flash_prev : just flash previously built image" \
                                            "with fastboot"
elif [ "$1" == "boot_prev" ]; then
    boot_target prev-boot.img
elif [ "$1" == "flash_prev" ]; then
    flash_target prev-boot.img
else
    if ! [ -f $LINUX_DIR/arch/arm/boot/zImage ]; then
        echo "Error: missing zImage" >&2
    else
        build_boot_img
        if [ "$1" == "boot" ]; then
            boot_target $BUILD_DIR/build/$BUILD_TIME/boot.img
        elif [ "$1" == "flash" ]; then
            flash_target $BUILD_DIR/build/$BUILD_TIME/boot.img
        fi
    fi
fi
