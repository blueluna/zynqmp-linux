# Linux kernel

## Kernel configuration changes

First make changes

```
ARCH=arm64 make menuconfig
```

Then build and test

Lastly generate a new defconfig

```
ARCH=arm64 make savedefconfig
cp defconfig ../te0802_02_defconfig
```
