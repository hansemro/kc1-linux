[WIP] postmarketOS Install Guide
--------------------------------

## TODO Install pmbootstrap

```
$ pip3 install --user pmbootstrap
```

Optionally, install tab-completion

## Copy configuration

```
## pwd=kc1-linux
$ cp config/pmbootstrap.cfg ~/.config/
```

## Copy device and kernel packages

```
## pwd=kc1-linux
cp -r pmOS/device-amazon-otter ~/pmaports/device/testing/
cp -r pmOS/linux-amazon-otter ~/pmaports/device/testing/
```

Copy patches:

```
## pwd=kc1-linux
cp -r patches/* ~/pmaports/device/testing/linux-amazon-otter/
```

## TODO Build

## TODO Install

## TODO Post-Install Setup

### Recommended packages

- `postmarketos-ui-xfce4`: xfce4 desktop environment
- `xvkbd`: X11 onscreen keyboard


## Resources

- https://wiki.postmarketos.org/wiki/Installing_pmbootstrap
