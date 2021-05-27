setenv mmcnum ${mmcdev}
setenv mmcpart ${bootpart}
setenv bootargs init=/init.sh rw console=tty0 console=tty02 PMOS_NO_OUTPUT_REDIRECT PMOS_FORCE_PARTITION_RESIZE
setenv dtbootargs ${bootargs}
echo Loading initramfs
load mmc ${mmcnum}:${mmcpart} 0x82000000 /uInitrd-amazon-otter
echo Loading kernel
load mmc ${mmcnum}:${mmcpart} 0x80008000 /vmlinuz-amazon-otter
echo Loading fdt
load mmc ${mmcnum}:${mmcpart} 0x84000000 /omap4-kc1.dtb
echo Booting kernel
echo bootargs: ${bootargs}
bootz 0x80008000 0x82000000 0x84000000
