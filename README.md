Mainline Linux on (First Generation) Kindle Fire
================================================

Maintained by Hansem Ro (`hansemro@outlook.com`).

This repo contains documentation for bringing up mainline Linux on First Generation Kindle Fire tablet (also known as Otter or KC1).

Status
======

With some patches to mainline kernel, the device can boot into userspace with several devices working. Testing has been done on v5.12 kernel with a personally-built postmarketOS rootfs.

### Device Tree Status Table

| Hardware           | Status  | Comments |
| ------------------ | ------- | -------- |
| CPU                | Works   | TI OMAP4430 |
| GPU                | &cross; | PowerVR SGX540 |
| LPDDR2             | Works   | 512MB |
| eMMC               | Works   | 8GB; currently mapped to `/dev/mmcblk0` |
| UART               | Works   | UART3 = `/dev/ttyO2` |
| DSS/Framebuffer    | Works   | omapdrm successfully registers framebuffer |
| LCD Panel          | Works   | [MIPI DPI] 1024x600 32 bits/pixel |
| LCD Backlight      | Partial | GPTimer10 PWM driven; simple on/off support only |
| Touchscreen        | Works   | [i2c] Ilitek 2107; requires additional kernel patches |
| PMIC               | Partial | TI TWL6030 |
| Green LED          | Works   | TWL6030 PWM led |
| Orange LED         | Works   | TWL6030 PWM led |
| Power Button       | Works   | TI TWL6030 |
| RTC                | Works   | TI TWL6030 |
| Battery            | Works   | 3V3 4400mAh Li-Ion Battery |
| Fuel Gauge         | Works   | [i2c] TI BQ27541 |
| Charger Controller | Works   | [i2c] Sumit SMB347 |
| USB Gadget/OTG     | Works   | CDC/ACM gadget works; OTG works |
| WLAN               | Works   | [MMC/SDIO] TI WL1271 |
| Accelerometer      | &cross; | [i2c] Bosch BMA250 |
| Audio              | &cross; | TI TWL6040 |
| Audio Codec        | &cross; | [i2c] TI AIC3110 |
| Temperature Sensor | Works   | [i2c] National Semiconductor/TI LM75 ~ TI TMP105 |
| Light Sensor       | &cross; | [i2c] Sensortek STK22x7 |
| SmartReflex        | &cross; | dmesg reports errors |

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
- `picocom` or a similar UART communication program

### Setting up and connecting to UART port

TODO: Add hardware guide based off information found [here](https://web.archive.org/web/20141225213214/http://forum.xda-developers.com/showthread.php?t=1471813).

Build Guide
===========

Start by cloning this repo which contains configuration files and some helper scripts used in the steps below:

```
$ git clone https://github.com/hansemro/kc1-linux
```

### Recommended udev rules:

Add to `/etc/udev/rules.d/50-kc1.rules`:
```
SUBSYSTEM=="usb", ATTR{idVendor}=="1949", MODE="0666"
SUBSYSTEM=="usb",ATTR{idVendor}=="1949",ATTR{idProduct}=="0004",SYMLINK+="android_adb"
SUBSYSTEM=="usb",ATTR{idVendor}=="1949",ATTR{idProduct}=="0004",SYMLINK+="android_fastboot"

SUBSYSTEM=="usb", ATTR{idVendor}=="1949", MODE="0666"
SUBSYSTEM=="usb",ATTR{idVendor}=="1949",ATTR{idProduct}=="0007",SYMLINK+="android_adb"
SUBSYSTEM=="usb",ATTR{idVendor}=="1949",ATTR{idProduct}=="0007",SYMLINK+="android_fastboot"

SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666"
SUBSYSTEM=="usb",ATTR{idVendor}=="18d1",ATTR{idProduct}=="0100",SYMLINK+="android_adb"
SUBSYSTEM=="usb",ATTR{idVendor}=="18d1",ATTR{idProduct}=="0100",SYMLINK+="android_fastboot"

SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666"
SUBSYSTEM=="usb",ATTR{idVendor}=="18d1",ATTR{idProduct}=="d001",SYMLINK+="android_adb"
SUBSYSTEM=="usb",ATTR{idVendor}=="18d1",ATTR{idProduct}=="d001",SYMLINK+="android_fastboot"

SUBSYSTEM=="usb", ATTR{idVendor}=="0451", MODE="0666"
SUBSYSTEM=="usb",ATTR{idVendor}=="0451",ATTR{idProduct}=="d00f",SYMLINK+="android_adb"
SUBSYSTEM=="usb",ATTR{idVendor}=="0451",ATTR{idProduct}=="d00f",SYMLINK+="android_fastboot"
```

Reload udev rules:
```
$ sudo udevadm control --reload-rules
$ sudo udevadm trigger
```

### Toolchain

You can decide whether to use a prebuilt toolchain or compile your own with `crosstool-ng`. If you are unsure, just use a prebuilt toolchain from official GCC, Linaro, or Bootlin. Do note that most toolchain vendors provide two toolchain variants: one for baremetal (usually labeled as none) and another for Linux.

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

### aboot.bin + omapboot

`omapboot` works more reliably than omap4boot, but we will still want to compile `aboot.bin` from omap4boot repo.

```
## pwd=kc1-linux/
$ git clone https://github.com/al177/omap4boot.git
$ git clone https://github.com/kousu/omapboot.git
$ cd omap4boot
$ make TOOLCHAIN=${LIN49_ARM_EABI}
## Copy aboot.bin somewhere convenient
$ cp out/panda/aboot.bin ~/
$ cd ../omapboot
$ pip3 install pyusb
## install omapboot to ~/.local/bin:
$ python setup.py develop --user
$ export PATH=$PATH:~/.local/bin
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
## My fork: https://github.com/hansemro/linux.git
$ git clone https://github.com/torvalds/linux.git mainline
$ cp scripts/make-linux.sh mainline/make.sh
$ cp config/omap4_kc1.config mainline/.config
$ cp patches/*.patch mainline/
$ cd mainline
$ git checkout v5.12
## Apply 0001 patch if you are using upstream's devicetree (not from this repo)
## Patch 0004 is no longer needed, but it doesn't hurt to have it applied either.
$ patch -p1 < 0001*.patch
$ patch -p1 < 0002*.patch
$ patch -p1 < 0003*.patch
$ patch -p1 < 0005*.patch
$ cp config/omap4-kc1*dts* mainline/arch/arm/boot/dts
## make.sh usage:
##    ./make.sh          : build kernel (arch/arm/boot/zImage)
##                         + modules (arch/arm/boot/lib/modules/)
##    ./make.sh clean    : clean up kernel + modules
##    ./make.sh command  : same as make ARCH=arm CROSS_COMPILE=... command
$ ./make.sh
```

### BusyBox Rootfs

This step is not mandatory. I am including it because the steps were simple. In the future, I plan to provide a postmarketOS rootfs port.

```
## pwd kc1-linux/
$ mkdir -p rootfs/etc/init.d/
$ cd rootfs
$ mkdir proc sys dev
$ cd ..
$ cp scripts/rcS rootfs/etc/init.d/
$ chmod +x rootfs/etc/init.d/rcS
$ git clone https://git.busybox.net/busybox
$ cp config/busybox.config busybox/.config
$ cd buxybox
$ make ARCH=arm CROSS_COMPILE=${LIN65_ARM_LHF} -j$(nproc)
$ make ARCH=arm CROSS_COMPILE=${LIN65_ARM_LHF} install
$ cd ../rootfs
$ tar -czvf ../rootfs.tar.gz ./
```

Install Guide
=============

Proceed to the following steps if you have access to built u-boot and kernel images.

Skip steps 1 and 3 if you already have TWRP with working adb installed.

### 1. (Rooting the Kindle Fire) and setting the device to fastboot mode

"Rooting" is only required if the Kindle Fire is on newer stock firmware (FireOS > 6.3.0) and the device cannot get access to fastboot mode by some other method (fastboot cable, custom bootloader, etc).

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

With adb, access the root shell to check if the device is rooted:

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

### 2. (Testing and) Installing U-Boot

Good practice: Use `omapboot/omap4boot/usbboot` utility to test bootloader images without flashing. This is merely a safety measure to prevent bricking your device.

In fastboot mode, flash u-boot bootloader: `$ fastboot flash bootloader u-boot.bin`

### 3. Installing TWRP recovery (and backuping data)

TWRP provides a useful set of tools for creating backups or installing images. However, we will be using TWRP frequently for transfering data between the build machine and the tablet.

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

The stock partition layout (as shown in `stock_partition_table.txt`) originally maps more space to user-controlled partition called `media`. However, the `media` partition doesn't serve much purpose for Linux. So to allocate more space to the root filesystem, I decided to shrink the `media` partition with enough space for TWRP and expand the `system` partition (as shown in `linux_partition_table.txt`). Feel free to approach this another way as many of these decisions were arbitrary.

```
## Note: take your liberties on userdata and cache partitions.
## While in recovery mode and connected to a computer, enter adb shell
$ adb shell
# parted /dev/block/mmcblk0
(parted) rm 10
(parted) rm 11
(parted) rm 12
(parted) resize 9
Start? [312MB]? 312MB
End? [849MB]? 4931MB
(parted) mkpart 10 4931 5443
(parted) mkpart 11 5443 5699
(parted) mkpart 12 5699 7235
(parted) name 10 userdata
(parted) name 11 cache
(parted) name 12 media
## Check your result with p (which prints partition layout)
(parted) p
...
(parted) quit
# mke2fs -T ext4 /dev/block/mmcblk0p9
# mke2fs -T ext4 /dev/block/mmcblk0p10
# mke2fs -T ext4 /dev/block/mmcblk0p11
# mkdosfs /dev/block/mmcblk0p12
```

Install rootfs onto the system partition:

```
## pwd=kc1-linux/
$ adb shell mount /dev/block/mmcblk0p9 /system
$ adb push rootfs.tar.gz /system
$ adb shell
# cd /system
# tar -xzvf rootfs.tar.gz ./
```

TODO: Setup inittab

```
## Inside adb shell with the system partition mounted
# echo "ttyO2::respawn:/sbin/getty -L ttyO2 115200 vt100" >> /system/etc/inittab
```

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
$ ./push_modules.sh adb
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

OMAP44xx SoC has a built-in usbboot mode that allows the device to boot into u-boot or a recovery image in whatever state the device is in.

usbboot mode can be triggered by any of the following methods:
- via pin shorting: described in this old [XDA post](https://forum.xda-developers.com/t/devs-needed-for-twrp-port.1356425/page-3#post-19762674)
- via UI option in Hashcode 2014 U-Boot port: navigate to the advanced menu option via power button
- via u-boot console command in Hashcode 2014 U-Boot port: run `kc1_usbboot`
- via fastboot: `fastboot oem idme bootmode 4003; fastboot reboot`
- via adb (recovery): `adb shell idme bootmode 4003; adb shell busybox reboot`

In the circumstance that the device cannot boot into a bootloader, the pin shorting method is the only method that can be used.

`omap4boot` Usage:
```
## pwd=kc1-linux
$ cd omap4boot/out/panda/
## Boot into TWRP recovery (for adb) or u-boot (for fastboot)
## Note: use omapboot if encountering repeated errors.
$ ./usbboot ./aboot.bin <twrp.img|u-boot.bin|kernel|2nd-stage>
```

(Recommended) `omapboot` Usage:
```
## Note: ignore messages about removing the battery.
$ omapboot ~/aboot.bin <twrp.img|u-boot.bin|kernel|2nd-stage>
```

The rest of the steps vary depending on what needs to be recovered.

Credits
=======

- Michael John Sakellaropoulos (brought up panel + drm support among other helpful work)
- Paul Kocialkowski (initial work on device tree for Kindle Fire)
- Andrew Litt (modified omap4boot/usbboot for Kindle Fire)
- Hashcode (U-Boot work for Kindle Fire)
- Linus Torvalds (Linux)
- Others who were also important in making this possible
