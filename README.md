Mainline Linux on (First Generation) Kindle Fire
================================================

Maintained by Hansem Ro (`hansemro@outlook.com`).

Documentation for bringing up mainline Linux on First Generation Kindle Fire tablet (also known as Otter or KC1).

Status
======

Mainline kernel boots with at least a working UART console and usb ethernet (CDC) gadget. However, many things do not work yet (such as framebuffer and audio) with the current device tree.

Note that older kernels that were used for Android have more functional drivers (such as support for framebuffer and touchscreen).

Setup
=====

### Hardware Requirements

This project requires the following:

- Kindle Fire tablet (first generation only)
- 1V8 UART interface
- Linux build machine (assuming `x86_64`)

### Software Requirements

- TODO (Please refer to build requirements for kernel and u-boot for your distro)

Build Guide
===========

### Toolchain

For this project, we will be using Linaro 4.9 for u-boot and Linaro 6.5 for the Linux kernel.

```
# Create a directory for arm toolchains; Change location if needed
mkdir ~/arm_toolchains
cd ~/arm_toolchains
wget https://releases.linaro.org/components/toolchain/binaries/4.9-2017.01/arm-eabi/gcc-linaro-4.9.4-2017.01-x86_64_arm-eabi.tar.xz
wget https://releases.linaro.org/components/toolchain/binaries/6.5-2018.12/arm-linux-gnueabihf/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz
tar -xvf gcc-linaro-4.9*.tar.xz
tar -xvf gcc-linaro-6.5*.tar.xz
```

Add the following to `~/.bashrc` and then source it:

```
export ARM_TOOLCHAINS_DIR=$HOME/arm_toolchains
export LIN49_ARM_EABI=$ARM_TOOLCHAINS_DIR/gcc-linaro-4.9-2016.02-x86_64_arm-eabi/bin/arm-eabi-
export LIN65_ARM_LHF=$ARM_TOOLCHAINS_DIR/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
```

### U-Boot (based off Hashcode fork)

```
# pwd=kc1-linux/
git clone https://github.com/hansemro/kf_u-boot.git u-boot
cp scripts/make-uboot.sh u-boot/make.sh
cd u-boot
./make.sh
```

### Linux

You may encounter errors while building the kernel. Fortunately, many of which have solutions that can be looked up. Patches to fix build issues may come in the future.

```
git clone https://github.com/hansemro/linux.git mainline
cp scripts/make-linux.sh mainline/make.sh
cp config/omap4_kc1.config mainline/.config
cp config/omap4-kc1.dts mainline/arch/arm/boot/dts/
cd mainline
git checkout f40ddce88593482919761f74910f42f4b84c004b
# make.sh usage:
#    ./make.sh          : build kernel (arch/arm/boot/zImage)
#                         + modules (arch/arm/boot/lib/modules/)
#    ./make.sh clean    : clean up kernel + modules
#    ./make.sh command  : same as make ARCH=arm CROSS_COMPILE=... command
./make.sh
```

Install Guide
=============

Proceed to the following steps if you have access to built u-boot and kernel images.

Skip steps 1 and 3 if you already have TWRP with working adb installed.

### 1. Rooting the Kindle Fire

TODO: Finish step

### 2. Installing U-Boot

In fastboot mode, flash u-boot bootloader: `$ fastboot flash bootloader u-boot.bin`

### 3. Installing TWRP recovery (and backuping data)

TWRP provides a useful set of linux tools for creating backups or installing images. However, we will be using TWRP frequently for transfering data between the build machine and the tablet.

Download twrp for the Kindle Fire (Otter) [here](https://twrp.me/amazon/amazonkindlefire.html).

In fastboot mode, flash the recovery: `$ fastboot flash recovery twrp-*-otter.img`

#### Backing up partitions while in recovery mode

Set the kindle to recovery mode and run the following when the PC detects the kindle in adb mode.

```
# pwd=kc1-linux/
mkdir backups
cd backups
adb pull /mnt/block/mmcblk0boot0 mmcblk0boot0.img
adb pull /mnt/block/mmcblk0boot1 mmcblk0boot1.img
for i in 1 2 .. 12; do adb pull /dev/block/mmcblk0p$i mmcblk0p$i.img; done
adb pull /proc/partitions partitions.txt
adb shell "echo "p" | parted /dev/block/mmcblk0" > partition_info.txt
```

### 4. Repartitioning and Installing rootfs

TODO: Repartition with parted tool while in recovery

TODO: Install rootfs

### 5. Installing Kernel + Modules + DTB

TODO: Finish step

```
# pwd=kc1-linux/mainline/
# While in recovery, mount system partition
adb shell mount /dev/block/mmcblk0p9 /system
# installing kernel and dtb in /boot/ of the system partition
adb push arch/arm/boot/zImage /system/boot/
adb push arch/arm/boot/dts/omap4-kc1.dtb /system/boot/
# TODO: installing modules
```

### 6. Booting Kernel

TODO: Finish step

Enter U-Boot console (accessed only via UART console) and run the following to boot the kernel (with dtb) in the system partition (mmcblk0p9).

```
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
git clone https://github.com/al177/omap4boot.git
cd omap4boot
make TOOLCHAIN=${LIN49_ARM_EABI}
cd out/panda/
# Boot into TWRP recovery (for adb) or u-boot (for fastboot)
./usbboot ./aboot.bin <twrp.img|u-boot.bin>
```

Credits
=======

- Paul Kocialkowski (initial work on device tree for Kindle Fire)
- Andrew Litt (modified omap4boot/usbboot for Kindle Fire)
- Hashcode (U-Boot work for Kindle Fire)
- Linus Torvalds (Linux)
- Others who were also important in making this possible
