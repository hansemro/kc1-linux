#!/usr/bin/env bash

# Maintained by Hansem Ro (hansemro@outlook.com)

# Push Linux modules via adb (while in recovery mode)
#
# Usage: ./push_modules.sh <help|adb|ssh>

# Change LIN_VERSION to kernel version that shows up
# at lib/modules/<version>

LIN_VERSION=5.12.0+
LINUX_DIR="$PWD/.."
BUILD_DIR="$PWD"

# Device info
SYSTEM_PART_NUM=9
DEVICE_ADDRESS=192.168.5.1

rm -rf ./$LIN_VERSION
#cp -r $LINUX_DIR/lib/modules/$LIN_VERSION ./
cp -r $BUILD_DIR/lib/modules/$LIN_VERSION ./

print_help() {
    echo "./push_modules.sh help"
    echo "./push_modules.sh adb"
    echo "./push_modules.sh ssh"
}

if [ "$1" == "help" ]; then
    print_help
elif [ "$1" == "adb" ]; then
    TRIES=1
    STATUS=$(adb devices | tail -n +2 | awk '{print $2}')
    while [ "$STATUS" != "recovery" ] && [ $TRIES -lt 5 ]; do
        echo "Device not found; sleeping for 5 seconds..."
        ((TRIES++))
        echo "Attempt $TRIES"
        sleep 5
        STATUS=$(adb devices | tail -n +2 | awk '{print $2}')
    done
    if [ "$STATUS" == "recovery" ]; then
        echo "Device found; copying $LIN_VERSION modules to system..."
        adb shell mount /dev/block/mmcblk0p$SYSTEM_PART_NUM /system
        adb shell mkdir -p /system/lib/modules/backup
        adb shell rm -rf /system/lib/modules/$LIN_VERSION
        adb push $LIN_VERSION/ /system/lib/modules/
        adb shell sync
    fi
elif [ "$1" == "ssh" ]; then
	scp -r $LIN_VERSION root@$DEVICE_ADDRESS:/lib/modules/
else
    print_help
fi
