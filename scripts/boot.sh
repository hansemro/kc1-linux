#!/usr/bin/env bash

# Boot previously created boot image (prev-boot.img)

# Usage: ./boot.sh

if [ -f prev-boot.img ]; then
    ORIG=$(readlink prev-boot.img)
    echo "Booting $ORIG"
    fastboot boot prev-boot.img
fi
