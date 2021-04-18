#!/usr/bin/env bash

# Maintained by Hansem Ro (hansemro@outlook.com)

# Push Linux modules via adb (while in recovery mode)
#
# Usage: ./push_modules.sh

# Change LIN_VERSION to kernel version that shows up
# at linux/arch/arm/boot/lin/modules/<version>
LIN_VERSION=5.11.0+

rm -rf ./$LIN_VERSION
cp -r ../arch/arm/boot/lib/modules/$LIN_VERSION ./
# adb shell mkdir /mnt
# adb shell mount /dev/block/mmcblk0p13 /mnt
# adb shell mount /dev/block/mmcblk0p9 /system
adb shell mkdir -p /system/lib/modules/backup
adb shell rm -rf /system/lib/modules/$LIN_VERSION
adb push $LIN_VERSION/ /system/lib/modules/
# adb shell umount /system
