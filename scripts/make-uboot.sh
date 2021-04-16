#!/usr/bin/env bash

# Maintained by Hansem Ro (hansemro@outlook.com)

# Usage:
#   ./make-uboot.sh         : build u-boot for kc1
#   ./make-uboot.sh clean   : cleanup u-boot (with distclean)

# Make script inspired by Hector Martin
# https://www.youtube.com/watch?v=x8f9-E_eP4M

ARCH=arm
CROSS_COMPILE=$LIN49_ARM_EABI
MK="make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE"

# https://stackoverflow.com/a/12199816
function show_time () {
    num=$1
    min=0
    hour=0
    day=0
    if((num>59));then
        ((sec=num%60))
        ((num=num/60))
        if((num>59));then
            ((min=num%60))
            ((num=num/60))
            if((num>23));then
                ((hour=num%24))
                ((day=num/24))
            else
                ((hour=num))
            fi
        else
            ((min=num))
        fi
    else
        ((sec=num))
    fi
    echo "$day"d "$hour"h "$min"m "$sec"s
}

if [ "$1" == "clean" ]; then
    $MK distclean
else
    SECONDS=0
    $MK distclean
    $MK omap4_kc1 -j4
    echo "$(show_time $SECONDS) seconds wasted"
    # usr/gen_init_cpio descriptor | gzip > initramfs.gz
fi
