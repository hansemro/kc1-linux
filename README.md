Mainline Linux on (First Generation) Kindle Fire
================================================

Maintained by Hansem Ro (`hansemro@outlook.com`).

Disclaimer: Your warranty is now void (if not already) and I am not responsible for any incurred damages. For assistance, reach out or submit an issue.

This repo contains documentation for bringing up mainline Linux on First Generation Kindle Fire tablet (also known as Otter or KC1).

Status
======

Mainline kernel boots with at least a working UART console and usb ethernet (CDC) gadget. However, many things do not work yet (such as framebuffer and audio) with the current device tree.

Note that older kernels that were used for Android have more functional drivers (such as support for framebuffer and touchscreen).

### Device Tree Status Table

| Hardware           | Status  | Comments |
| ------------------ | ------- | -------- |
| CPU                | &check; | TI OMAP4430 |
| GPU                | &cross; | PowerVR SGX540 |
| UART               | &check; | UART3 = `/dev/ttyO2` |
| eMMC               | &check; | Issue: device assigns to `/dev/mmcblk0` or `/dev/mmcblk1` |
| Green LED          | &check; | PWM led |
| Orange LED         | &check; | PWM led |
| Power Button       | &check; | TI TWL6030 |
| USB OTG            | &check; | GPIO |
| LCD Panel          | &cross; | 1024x600 16 bits/pixel |
| LCD Backlight      | &cross; | OMAP PWM |
| Framebuffer        | &cross; | Memory address at 0x9fec4000 ? |
| Battery            | &check; | 3V3 4400mAh Li-Ion Battery |
| PMIC               | &cross; | TI TWL6030 |
| WLAN               | &cross; | TI WL127x |
| Touchscreen        | &cross; | Ilitek 210x Touchscreen Controller |
| Accelerometer      | &cross; | Bosch BMA250 |
| Fuel Gauge         | &check; | TI BQ27541 |
| Charger Controller | &cross; | Sumit SMB347 |
| Audio              | &cross; | TI TWL6040 |
| Audio Codec        | &cross; | TI AIC3110 |
| Temperature Sensor | &cross; | National Semiconductor/TI LM75 ~ TI TMP105 |
| Light Sensor       | &cross; | Sensortek STK22x7 |
| LPDDR2             | &check; | emif? |
| RTC                | &check; | TI TWL6030 |

Setup
=====

### Hardware Requirements

This project requires the following:

- Kindle Fire tablet (first generation only)
- 1V8 UART interface
- Linux build machine (assuming `x86_64`)

### Software Requirements

- Android Platform Tools (adb, fastboot)
- TODO (Please refer to build requirements for kernel and u-boot for your distro)
- TODO udev rule for Kindle Fire

### Setting up and connecting to UART port

TODO: Add hardware guide based off information found [here](https://web.archive.org/web/20141225213214/http://forum.xda-developers.com/showthread.php?t=1471813).

Build Guide
===========

### Toolchain

You can decide whether to use a prebuilt toolchain or compile your own with `crosstool-ng`. If you are unsure, just use a prebuilt toolchain from Linaro or Bootlin.

#### Prebuilt Toolchain

For this project, we will be using Linaro 4.9 for u-boot and Linaro 6.5 for the Linux kernel.

```
## <- This is a comment
## Create a directory for arm toolchains; Change location if needed
$ mkdir ~/arm_toolchains
$ cd ~/arm_toolchains
$ wget https://releases.linaro.org/components/toolchain/binaries/4.9-2017.01/arm-eabi/gcc-linaro-4.9.4-2017.01-x86_64_arm-eabi.tar.xz
$ wget https://releases.linaro.org/components/toolchain/binaries/6.5-2018.12/arm-linux-gnueabihf/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz
$ tar -xvf gcc-linaro-4.9*.tar.xz
$ tar -xvf gcc-linaro-6.5*.tar.xz
```

Add the following to `~/.bashrc` and then source it:

```
## Change ARM_TOOLCHAINS_DIR if necessary
export ARM_TOOLCHAINS_DIR=$HOME/arm_toolchains
export LIN49_ARM_EABI=$ARM_TOOLCHAINS_DIR/gcc-linaro-4.9-2016.02-x86_64_arm-eabi/bin/arm-eabi-
export LIN65_ARM_LHF=$ARM_TOOLCHAINS_DIR/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
```

#### crosstool-NG Toolchain

TODO: test with mainline kernel

```
## Building toolchain for linux
$ git clone https://github.com/crosstool-ng/crosstool-ng
$ cd crosstool-ng
$ ./bootstrap
$ ./configure --prefix=${crosstool-ng-install-location}
$ echo export PATH=\$PATH:${crosstool-ng-install-location/bin} >> ~/.bashrc
$ source ~/.bashrc
$ ct-ng list-samples
$ ct-ng show-arm-cortexa9_neon-linux-gnueabihf
$ ct-ng arm-cortexa9_neon-linux-gnueabihf
$ ct-ng nconfig
## Change linux headers if needed:
##		Operating System->Version of Linux
##
##		Note: 3.4.113 works for 3.4.x Android kernel by Hashcode
##
## Change C compiler version if needed:
## 		C compiler->Version of gcc
##
##		Note: 6.5.0 works for 3.4.x Android kernel by Hashcode
##
## then save the config and exit
$ ct-ng build.$(nproc)
```

### omap4boot

```
## pwd=kc1-linux/
$ git clone https://github.com/al177/omap4boot.git
$ cd omap4boot
$ make TOOLCHAIN=${LIN49_ARM_EABI}
```

### U-Boot (based off Hashcode fork)

```
## pwd=kc1-linux/
$ git clone https://github.com/hansemro/kf_u-boot.git u-boot
$ cp scripts/make-uboot.sh u-boot/make.sh
$ cd u-boot
$ ./make.sh
```

### mkbootimg

TODO: test with newer versions of mkbootimg

```
## pwd=kc1-linux/
$ git clone https://github.com/CyanogenMod/android_system_core.git
$ cd android_system_core/mkbootimg
$ echo "export PATH=$PWD:\$PATH" >> ~/.bashrc
$ export PATH=$PWD:$PATH
```

### Linux

You may encounter errors while building the kernel. Fortunately, many of which have solutions that can be looked up. Patches to fix build issues may come in the future.

```
## pwd=kc1-linux/
$ git clone https://github.com/hansemro/linux.git mainline
$ cp scripts/make-linux.sh mainline/make.sh
$ cp config/omap4_kc1.config mainline/.config
$ cp config/omap4-kc1.dts mainline/arch/arm/boot/dts/
$ cd mainline
$ git checkout f40ddce88593482919761f74910f42f4b84c004b
## make.sh usage:
##    ./make.sh          : build kernel (arch/arm/boot/zImage)
##                         + modules (arch/arm/boot/lib/modules/)
##    ./make.sh clean    : clean up kernel + modules
##    ./make.sh command  : same as make ARCH=arm CROSS_COMPILE=... command
$ ./make.sh
```

Install Guide
=============

Proceed to the following steps if you have access to built u-boot and kernel images.

Skip steps 1 and 3 if you already have TWRP with working adb installed.

### 1. (Rooting the Kindle Fire) and setting the device to fastboot mode

"Rooting" is only required if the Kindle Fire is on newer stock firmware (FireOS > 6.3.0) and the device cannot get access to fastboot mode by another method.

```
## Get saferoot.zip
## Relevant xda post:
## https://forum.xda-developers.com/t/root-saferoot-root-for-vruemj7-mk2-and-android-4-3.2565758/#post-48392009
##
##  1) Enable USB Debugging
##  2) Enable USB ADB access
##  3) Root with saferoot.zip
$ wget https://forum.xda-developers.com/attachments/saferoot-zip.2760984/ -O saferoot.zip
$ mkdir saferoot
$ cd saferoot
$ unzip ../saferoot.zip
$ ./install.sh
```

To check if you have root, run the following:

```
## from a computer
$ adb shell
(adb)$ su
## If you see the prompt change to `#`, then the device was successfully rooted!
```

With root, we can use a utility called fbmode to set the Kindle Fire to fastboot mode.

```
## Get fbmode.zip
## Relevant xda post:
## https://forum.xda-developers.com/t/fastboot-stock-6-2-1-fastboot-mode-without-rooting-or-cables.1414832/
$ wget https://forum.xda-developers.com/attachments/fbmode-zip.833582/ -O fbmode.zip
$ unzip fbmode.zip
$ adb push fbmode /data/local/tmp
$ adb shell chmod 755 /data/local/tmp/fbmode
$ adb shell /data/local/tmp/fbmode
$ adb reboot
```

The Kindle should now be in fastboot mode. Check `fastboot devices` to see if the Kindle is properly identified and accessible.

### 2. Installing U-Boot

Good practice: Test the bootloader before flashing with `omap4boot/usbboot`. This is to prevent potential bricks caused by a bad bootloader.

In fastboot mode, flash u-boot bootloader: `$ fastboot flash bootloader u-boot.bin`

### 3. Installing TWRP recovery (and backuping data)

TWRP provides a useful set of linux tools for creating backups or installing images. However, we will be using TWRP frequently for transfering data between the build machine and the tablet.

Download twrp for the Kindle Fire (Otter) [here](https://twrp.me/amazon/amazonkindlefire.html).

In fastboot mode, flash the recovery: `$ fastboot flash recovery twrp-*-otter.img`

#### Backing up partitions while in recovery mode

Set the kindle to recovery mode and run the following when the PC detects the kindle in adb mode.

```
## pwd=kc1-linux/
$ mkdir backups
$ cd backups
$ adb pull /mnt/block/mmcblk0boot0 mmcblk0boot0.img
$ adb pull /mnt/block/mmcblk0boot1 mmcblk0boot1.img
$ for i in 1 2 .. 12; do adb pull /dev/block/mmcblk0p$i mmcblk0p$i.img; done
$ adb pull /proc/partitions partitions.txt
$ adb shell "echo "p" | parted /dev/block/mmcblk0" > partition_info.txt
```

### 4. Repartitioning and Installing rootfs

TODO: Repartition with parted tool while in recovery

#### Modified partition layout:

TODO: Improve layout and add steps

Goal: Expand system partition; Shrink media partition

```
## Modified partition layout below
## Use parted to resize (resize), remove (rm),
## and make (mkpart) partitions
## Afterwards, use mke2fs to format partitions
$ adb shell
# parted /dev/block/mmcblk0
(parted) print
Model: MMC M8G2FA (sd/mmc)
Disk /dev/block/mmcblk0: 7734MB
Sector size (logical/physical): 512B/512B
Partition Table: gpt

Number  Start   End     Size    File system  Name        Flags
 1      131kB   262kB   131kB                xloader
 2      262kB   524kB   262kB                bootloader
 3      524kB   11.0MB  10.5MB               dkernel
 4      11.0MB  212MB   201MB                dfs
 5      212MB   229MB   16.8MB               recovery
 6      229MB   296MB   67.1MB               backup
 7      296MB   307MB   10.5MB               boot
 8      307MB   312MB   5243kB               splash
 9      312MB   4931MB  4619MB  ext4         system
10      4931MB  5443MB  512MB   ext4         userdata
11      5443MB  5699MB  256MB   ext4         cache
12      5699MB  7235MB  1536MB  fat16        media       msftres
```

TODO: formatting steps

TODO: Install rootfs

TODO: Setup inittab

`echo "ttyO2::respawn:/sbin/getty -L ttyO2 115200 vt100" >> /system/etc/inittab`

TODO: Install (non-free) TI WIFI firmware

### 5. Installing/Booting Kernel + DTB + Modules

There are two main ways to load the kernel:

1. boot as Android boot image
2. manual booting with U-Boot commands

For ease of use, go with method 1 (via Script method). However, you can't go wrong with method 2 if want to make sure everything is working correctly.

#### Script method

Install scripts to a build directory in the kernel directory.

```
## pwd=kc1-linux/mainline
## Prepare build directory with scripts
$ mkdir -p build
$ cp ../scripts/build_boot.sh build/
$ cp ../scripts/boot.sh build/
$ cp ../scripts/push_modules.sh build/
```

Install with scripts:

```
## pwd=kc1-linux/mainline/boot
## While in recovery, mount system partition
$ adb shell mount /dev/block/mmcblk0p9 /system
## Push kernel modules to system partition
$ ./push_modules.sh
## Install kernel+dtb as Android boot image
##
## build_boot.sh usage:
##    ./build_boot.sh            : build Android boot image
##    ./build_boot.sh help       : print help message
##    ./build_boot.sh boot       : build and boot Android boot image
##    ./build_boot.sh boot_prev  : boot previously built image
##    ./build_boot.sh flash      : build and flash Android boot image
##    ./build_boot.sh flash_prev : flash previously built image
##
## RECOMMENDED: Flash if you are condident the image is stable
##              and boot if you are just testing.
$ ./build_boot.sh flash
```

Tip for testing device tree changes:

Since the kernel does not have to be recompiled whenever you modify the device tree, you can just rebuild the boot image with the new blobs.

```
## pwd=kc1-linux/mainline
## Step 1: build dtb
$ ./make.sh dtb
## Step 2: build boot image
$ cd build
$ ./build_boot.sh [build|flash]
```

#### Manual method

Install the kernel, dtb, and kernel modules in system partition:

```
## pwd=kc1-linux/mainline/
## While in recovery, mount system partition
$ adb shell mount /dev/block/mmcblk0p9 /system
## installing kernel and dtb in /boot/ of the system partition
$ adb push arch/arm/boot/zImage /system/boot/
$ adb push arch/arm/boot/dts/omap4-kc1.dtb /system/boot/
## remove conflicting modules directory if present
$ adb shell rm -rf /system/lib/modules/$LIN_VERSION
$ adb push arch/arm/boot/lib/modules/$LIN_VERSION /system/lib/modules/
$ adb shell sync
```

Reboot and enter U-Boot console (accessed only via UART console). Then run the following to boot the kernel (with dtb) in the system partition (mmcblk0p9).

```
## Connect to Kindle over UART
$ picocom /dev/ttyUSB0 -b 115200
## Power up the Kindle and mash `Esc` in the
## terminal window as u-boot starts up.
U-Boot# run mmcargs_new
U-Boot# setenv dtbootargs ${dtbootargs} root=/dev/mmcblk0p9
U-Boot# load mmc 1:9 0x8100000 boot/zImage
U-Boot# load mmc 1:9 0x9100000 boot/omap4-kc1.dtb
U-Boot# bootz 0x81000000 - 0x91000000
```

The device should now boot into Linux with UART console still active.

Note: It is possible to load the kernel and device tree blob over serial, but it is very slow and not recommended.

Brick Recovery
==============

TODO: Create recovery guide based off usbboot mechanism.

```
$ cd kc1-linux/omap4boot/out/panda/
## Boot into TWRP recovery (for adb) or u-boot (for fastboot)
$ ./usbboot ./aboot.bin <twrp.img|u-boot.bin>
```

Credits
=======

- Paul Kocialkowski (initial work on device tree for Kindle Fire)
- Andrew Litt (modified omap4boot/usbboot for Kindle Fire)
- Hashcode (U-Boot work for Kindle Fire)
- Linus Torvalds (Linux)
- Others who were also important in making this possible
