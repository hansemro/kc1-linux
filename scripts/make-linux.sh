#!/usr/bin/env bash

# Maintained by Hansem Ro (hansemro@outlook.com)

# Usage:
#   ./make-linux.sh         : build kernel + modules
#   ./make-linux.sh clean   : cleanup kernel and modules
#   ./make-linux.sh command : same as make ARCH=arm CROSS_COMPILE=... command

# Make script inspired by Hector Martin
# https://www.youtube.com/watch?v=x8f9-E_eP4M

ARCH=arm
CROSS_COMPILE=$LIN65_ARM_LHF
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
    $MK clean
    rm -rf arch/arm/boot/lib
    rm -rf arch/arm/boot/dts/*.dtb
elif [ "$1" == "dtb" ]; then
    cpp -nostdinc -I include -I arch  -undef -x assembler-with-cpp arch/arm/boot/dts/omap4-kc1.dts arch/arm/boot/dts/omap4-kc1.dts.preprocessed
    dtc -I dts -O dtb arch/arm/boot/dts/omap4-kc1.dts.preprocessed -o arch/arm/boot/dts/omap4-kc1.dtb
elif [ "$1" != "" ]; then
    $MK $1
else
    SECONDS=0
    $MK clean
    rm -rf arch/arm/boot/lib
    $MK CONFIG_DEBUG_SECTION_MISMATCH=y -j4
    $MK INSTALL_MOD_PATH=arch/arm/boot modules_install
    echo "$(show_time $SECONDS) seconds wasted"
    # usr/gen_init_cpio descriptor | gzip > initramfs.gz
fi
