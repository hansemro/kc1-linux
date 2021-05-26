setenv mmcnum 1
setenv mmcpart 9
setenv mmctype ext4
setenv bootargs init=/init.sh root=/dev/mmcblk0p9 rw console=tty0 console=tty02 PMOS_NO_OUTPUT_REDIRECT PMOS_FORCE_PARTITION_RESIZE
setenv dtbootargs ${bootargs}
echo Loading initramfs
load mmc ${mmcnum}:${mmcpart} 0x82000000 /boot/uInitrd-amazon-otter
echo Loading kernel
load mmc ${mmcnum}:${mmcpart} 0x80008000 /boot/vmlinuz-amazon-otter
echo Loading fdt
load mmc ${mmcnum}:${mmcpart} 0x84000000 /boot/omap4-kc1.dtb
echo Booting kernel
echo bootargs: ${bootargs}
bootz 0x80008000 0x82000000 0x84000000
