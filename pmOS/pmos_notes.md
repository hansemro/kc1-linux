postmarketOS Porting Notes
--------------------------

## Configuration

`~/.config/pmbootstrap.cfg`:
```
[pmbootstrap]
aports = /home/clfs/.local/var/pmbootstrap/cache_git/pmaports
ccache_size = 5G
is_default_channel = False
device = amazon-otter
extra_packages = vim,bc,bind-tools,bison,coreutils,curl,dtc,flex,gcc,gtk+3.0,htop,i2c-tools,kbd,libgpiod,make,xvkbd,musl-dev,ncurses-dev,openssl-dev,pm-utils,py3-gobject3,strace,terminus-font,wireless-tools,wpa_supplicant
hostname =
build_pkgs_on_install = True
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
boot_size = 40
locale = en_US.UTF-8
extra_space = 0
sudo_timer = False
```

## Variables and Locations:

`linux-amazon-otter/APKBUILD`:
- `srcdir`: `~/.local/var/pmbootstrap/chroot_native/home/pmos/build/src`
- `pkgdir`: `~/.local/var/pmbootstrap/chroot_native/home/pmos/build/pkg`

## Cleaning pmbootstrap environment

I noticed pmbootstrap environment can get dirty and affect future builds. This is what I do to reset/clean my environment:

Zap live and existing chroot environments:
```
$ pmbootstrap zap -m
```

Remove chroot and pmaports directories
```
$ sudo rm -rf ~/.local/var/pmbootstrap
```

Remove existing configuration:
```
$ rm ~/.config/pmbootstrap.cfg
```
