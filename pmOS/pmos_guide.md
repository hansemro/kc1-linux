postmarketOS Build and Install Guide
------------------------------------

postmarketOS provides a self-contained build utility called pmbootstrap. It can build kernel and rootfs among other things.

## Install and setup pmbootstrap

Optionally, install [argcomplete](https://wiki.postmarketos.org/wiki/Installing_pmbootstrap#Tab_completion) for tab completion.

```
## pwd=kc1-linux
$ pip3 install --user pmbootstrap
$ pmbootstrap init
$ ln -s ~/.local/var/pmbootstrap/cache_git/pmaports ~/pmaports
```

## Copy device and kernel packages

```
## pwd=kc1-linux
$ cp -r pmOS/device-amazon-otter ~/pmaports/device/testing/
$ cp -r pmOS/linux-amazon-otter ~/pmaports/device/testing/
```

Copy patches:

```
## pwd=kc1-linux
$ cp -r patches/* ~/pmaports/device/testing/linux-amazon-otter/
```

## Build

```
$ pmbootstrap checksum linux-amazon-otter
$ pmbootstrap build --force linux-amazon-otter
$ pmbootstrap checksum device-amazon-otter
$ pmbootstrap build --force device-amazon-otter
$ pmbootstrap install --split
```

## Install

### U-Boot Setup (L2.13 or newer required)

Since postmarketOS prefers separate root and boot partitions, we will need to define where to install each. Fortunately, because u-boot source is easily mendable, we can tell the postmarketOS bootscript which partitions to load. By default, u-boot defines partitions 11 and 12 as boot and root partitions, respectively.

If the boot partition is located somewhere else, we will need to modify u-boot to tell it where the boot script is located. To do so, just modify `bootpart` and `rootpart` environment variables under `CONFIG_EXTRA_ENV_SETTINGS` in `u-boot/include/configs/omap4_kc1.h`, recompile, and reinstall. Note that numbers in u-boot are represented in hex by default.

### Fastboot Install

#### Installation scenario: Stock layout
- Install root to `/dev/mmcblk0p12` aka `media` partition (5380MB)
- Install boot to `/dev/mmcblk0p11` aka `cache` partition (268MB)

```
$ pmbootstrap export
$ fastboot flash media /tmp/postmarketOS-export/amazon-otter-root.img
$ fastboot flash cache /tmp/postmarketOS-export/amazon-otter-boot.img
```

#### Installation scenario: Modified partition layout
- Install root to `/dev/mmcblk0p9`
- Install boot to `/dev/mmcblk0p11` aka `cache` partition

Set `bootpart` to 0xc and `rootpart` to 0x9 in `u-boot/include/configs/omap4_kc1.h`.

```
## pwd=kc1-linux/u-boot
$ ./make.sh
$ fastboot flash bootloader u-boot.bin
$ pmbootstrap export
$ fastboot flash system /tmp/postmarketOS-export/amazon-otter-root.img
$ fastboot flash cache /tmp/postmarketOS-export/amazon-otter-boot.img
```

### Manual Install

Installation scenario: Modified partition layout
- Install root to `/dev/mmcblk0p9`
- Install boot to `/dev/mmcblk0p11`

Set `bootpart` to 0xc and `rootpart` to 0x9 in `u-boot/include/configs/omap4_kc1.h`.

```
## pwd=kc1-linux/u-boot
$ ./make.sh
$ fastboot flash bootloader u-boot.bin
$ pmbootstrap export
$ sudo mkdir -p /mnt/boot
$ sudo mkdir -p /mnt/rootfs
$ sudo mount /tmp/postmarketOS-export/amazon-otter-boot.img /mnt/boot
$ sudo mount /tmp/postmarketOS-export/amazon-otter-root.img /mnt/rootfs
$ cd /mnt/boot && sudo tar -czvf /tmp/boot.tar.gz ./
$ cd /mnt/rootfs && sudo tar -czvf /tmp/rootfs.tar.gz ./
$ adb shell "mount /dev/block/mmcblk0p9 /system"
$ adb push /tmp/boot.tar.gz /cache
$ adb push /tmp/rootfs.tar.gz /system
$ adb shell "cd /system && tar -xzvf rootfs.tar.gz && rm rootfs.tar.gz"
$ adb shell "cd /cache && tar -xzvf boot.tar.gz && rm boot.tar.gz"
$ adb shell sync
$ adb shell "tune2fs -L pmOS_root /dev/block/mmcblk0p9"
$ adb shell "tune2fs -L pmOS_boot /dev/block/mmcblk0p11"
```

Cleanup:
```
$ sudo umount /mnt/rootfs
$ sudo umount /mnt/boot
$ sudo rm /tmp/boot.tar.gz /tmp/rootfs.tar.gz
```

## TODO Post-Install Setup

### Recommended packages

- `postmarketos-ui-xfce4`: xfce4 desktop environment
  - `lxdm`: needed for power options for xfce4
  - `network-manager-applet`
- `xvkbd`: X11 onscreen keyboard

## Resources

- https://gitlab.com/postmarketOS/pmaports/-/merge_requests/2202
- https://wiki.postmarketos.org/wiki/Installing_pmbootstrap
- https://wiki.postmarketos.org/wiki/Xfce4
- https://wiki.postmarketos.org/wiki/OnePlus_One_(oneplus-bacon)
