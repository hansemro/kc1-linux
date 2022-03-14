# Commented lines added by Makefile
#setenv linux_mmc_bootpart c
#setenv bootargs "console=ttyS2,115200 rw rootwait root=/dev/mmcblk0p12"
setenv kernelfile /boot/uImage.omap4-kc1
setenv scriptfile /boot/boot.scr
setenv linux_kernel_boot 'load mmc ${boot_mmc_dev}:${linux_mmc_bootpart} ${loadaddr} ${kernelfile}'
setenv linux_script_boot 'load mmc ${boot_mmc_dev}:${linux_mmc_bootpart} ${loadaddr} ${scriptfile}'
setenv recovery_boot 'part start mmc ${boot_mmc_dev} ${recovery_mmc_part} recovery_mmc_start; part size mmc ${boot_mmc_dev} ${recovery_mmc_part} recovery_mmc_size; mmc dev ${boot_mmc_dev}; mmc read ${loadaddr} ${recovery_mmc_start} ${recovery_mmc_size} && bootm ${loadaddr}'
setenv bootmenu_0 'Boot Linux kernel image=run linux_kernel_boot && bootm ${loadaddr}'
setenv bootmenu_1 'Boot Linux script=run linux_script_boot && source ${loadaddr}'
setenv bootmenu_2 'Boot Recovery=run recovery_boot'
setenv bootmenu_3 'Enter Fastboot=fastboot 0'
setenv bootmenu_4 'OMAP USBBOOT=kc1_usbboot'
setenv bootmenu_5 'Reboot=reset'
