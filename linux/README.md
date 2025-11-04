# Linux kernel

## Quick Start

Build mainline kernel and kernel modules for TE0802.

```shell
make
```

Install kernel modules into rootfs.

```shell
sudo make install_modules
```

## Building Linux kernel

```shell
git clone https://github.com/Xilinx/linux-xlnx.git
cd linux-xlnx
git checkout xilinx-v2022.1
```

```shell
CROSS_COMPILE=aarch64-linux-gnu- make defconfig ARCH=arm64
CROSS_COMPILE=aarch64-linux-gnu- make menuconfig ARCH=arm64
CROSS_COMPILE=aarch64-linux-gnu- make -j6 ARCH=arm64
```

### SPI device

https://yurovsky.github.io/2016/10/07/spidev-linux-devices.html


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
