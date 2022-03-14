# Commented lines added by Makefile
#setenv mmcpart c
#setenv bootargs "console=ttyS2,115200 console=tty1 root=/dev/mmcblk0p12 mem=512M rootwait"
setenv mmcnum 0
echo ${bootargs}
echo Loading kernel
load mmc ${mmcnum}:${mmcpart} 0x80008000 /boot/zImage
echo Loading fdt
load mmc ${mmcnum}:${mmcpart} 0x82000000 /boot/omap4-kc1.dtb
echo Booting kernel
bootz 0x80008000 - 0x82000000
