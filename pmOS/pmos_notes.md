postmarketOS Porting Notes
--------------------------

## Configuration

```
$ cat ~/.config/pmbootstrap.cfg
[pmbootstrap]
aports = /home/clfs/.local/var/pmbootstrap/cache_git/pmaports
ccache_size = 5G
is_default_channel = False
device = amazon-otter
extra_packages = vim,bc,bind-tools,bison,coreutils,curl,dtc,flex,gcc,gtk+3.0,htop,i2c-tools,kbd,libgpiod,make,xvkbd,musl-dev,ncurses-dev,openssl-dev,pm-utils,py3-gobject3,strace,terminus-font,wireless-tools,wpa_supplicant
hostname =
build_pkgs_on_install = False
jobs = 6
kernel = stable
keymap =
nonfree_firmware = True
nonfree_userland = False
ssh_keys = False
timezone = America/Los_Angeles
ui = none
ui_extras = False
user = user
work = /home/clfs/.local/var/pmbootstrap
boot_size = 100
locale = en_US.UTF-8
extra_space = 0
sudo_timer = False
```

## Questions

1. What is the best partition scheme for kindle? Standard Android layout is terrible.
  - Separate root + boot partitions ?
2. How can a user return to original partition scheme?
  - Use `oem format` fastboot command
  - Restore from backup
  - Manual restoration with the help of tools in recovery
3. How should postmarketOS be installed?
  - All traditional installation methods are broken. I have been manually converting rootfs.img to tarballs that I can extract.
4. How can I make postmarketOS build a bootable kernel?
  - Issue 1: device tree does not load (where is the device tree stored btw?)
  - Issue 2: boot fails with no serial console

## Reinstalling pmbootstrap

Zap live and existing chroot environments:
```
$ pmbootstrap zap
```

Remove chroot and pmaports directories
```
$ sudo rm -rf ~/.local/var/pmbootstrap
```

Remove existing configuration:
```
$ rm ~/.config/pmbootstrap.cfg
```
