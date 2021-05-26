postmarketOS Build and Install Guide
------------------------------------

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
$ pmbootstrap install
```

## Manual Install

Prerequisites:
- Install u-boot version L2.12 or greater.
- System partition (`/dev/mmcblk0p9`) greater than 200MB (preferably as large as possible)

```
## install multipath-tools for kpartx (for mounting convenience)
$ pmbootstrap export
$ sudo kpartx -a /tmp/postmarketOS-export/amazon-otter.img
$ sudo mkdir -p /mnt/boot
$ sudo mkdir -p /mnt/rootfs
$ sudo mount /dev/mapper/loop0p1 /mnt/boot
$ sudo mount /dev/mapper/loop0p2 /mnt/rootfs
$ cd /mnt/boot && sudo tar -czvf /tmp/boot.tar.gz ./
$ cd /mnt/rootfs && sudo tar -czvf /tmp/rootfs.tar.gz ./
$ adb shell "mount /dev/block/mmcblk0p9 /system"
$ adb push /tmp/boot.tar.gz /system
$ adb push /tmp/rootfs.tar.gz /system
$ adb shell "cd /system && tar -xzvf rootfs.tar.gz && rm rootfs.tar.gz"
$ adb shell "cd /system && tar -xzvf boot.tar.gz -C boot/ && rm boot.tar.gz"
$ adb shell "cd /system/boot && cp uImage-* uImage-amazon-otter && cp uInitrd-* uInitrd-amazon-otter"
$ adb shell sync
```

Cleanup:
```
$ sudo umount /mnt/rootfs
$ sudo umount /mnt/boot
$ sudo kpartx -d /tmp/postmarketOS-export/amazon-otter.img
$ sudo rm /tmp/boot.tar.gz /tmp/rootfs.tar.gz
```

## TODO Post-Install Setup

### Recommended packages

- `postmarketos-ui-xfce4`: xfce4 desktop environment
  - `lxdm`: needed for power options for xfce4
  - `network-manager-applet`
- `xvkbd`: X11 onscreen keyboard

## Resources

- https://wiki.postmarketos.org/wiki/Installing_pmbootstrap
- https://wiki.postmarketos.org/wiki/Xfce4
