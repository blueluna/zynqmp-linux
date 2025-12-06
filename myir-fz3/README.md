# Myir FZ3

## Overview

Currently supported,

 - [x] PMUFW
 - [x] PSU init
 - [x] U-Boot SPL
 - [x] U-Boot
 - [x] Linux Kernel
 - [x] Debian
 - [x] SD-card
 - [x] Ethernet
 - [x] eMMC
 - [x] I^2^C EEPROM
 - [x] QSPI flash
 - [x] DisplayPort Video
 - [x] DisplayPort Audio
 - [x] Lima GPU
 - [x] PL

## eMMC

### Linux file system

Install `btrfs-progs`, `parted` and `rsync`.

Create a partition table

```shell
parted -s /dev/mmcblk1p1 mklabel gpt
```

Create a fat32 and a btrfs partition

```shell
# parted -s /dev/mmcblk1 mkpart primary fat32 0% 64MiB
# parted -s /dev/mmcblk1 mkpart primary btrfs 64MiB 100%
```

```shell
# parted -s /dev/mmcblk1 print
Model: MMC Q2J55L (sd/mmc)
Disk /dev/mmcblk1: 7617MB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name     Flags
 1      1049kB  67.1MB  66.1MB  btrfs        primary  msftdata
 2      67.1MB  7616MB  7549MB  btrfs        primary
```

Create a vfat and btrfs filesystem on the partitions

```shell
mkfs.vfat /dev/mmcblk1p1
mkfs.btrfs -f /dev/mmcblk1p2
```

Mount and copy the rootfs

```shell
mkdir -p /media/emmc
mount /dev/nvme0n1p1 /media/emmc
rsync -avrltD --exclude-from=exclude.txt / /media/emmc
```

`exclude.txt` looks like following,

```
/boot/*
/dev/*
/proc/*
/sys/*
/media/*
/mnt/*
/run/*
/tmp/*
/ddbr/*
/var/log/journal
```

Update `extlinux.conf` to use the eMMC rootfs,

```
root=/dev/nvme0n1p1 rootfstype=btrfs
```

## Ethernet PHY

Qualcomm/Atheros AR8035

## I2C eeprom

Onsemi/Catalyst CAT24C256W, 32 kib

```shell
dd if=/sys/bus/i2c/devices/i2c-1/1-0051/eeprom of=/home/erik/eeprom.bin bs=1 count=32768
```

```shell
xxd /home/erik/eeprom.bin
```

## QSPI NOR flash

Micron MT25QU256ABA1EW, 32 Mib

The flash layout is the following,
```
# cat /proc/mtd
dev:    size   erasesize  name
mtd0: 00100000 00001000 "fsbl"
mtd1: 00100000 00001000 "ssbl_config"
mtd2: 00400000 00001000 "ssbl"
mtd3: 00a00000 00001000 "linux"
mtd4: 01000000 00001000 "data"
```

### U-Boot configuration

```shell
apt-get install libubootenv-tool
```

Configure `/etc/fw_env.config`.

```
# Configuration file for fw_(printenv/setenv) utility.
# Up to two entries are valid, in this case the redundant
# environment sector is assumed present.
# MTD device name       Device offset   Env. size       Flash sector size
/dev/mtd1               0x00000          0x80000         0x10000
/dev/mtd1               0x80000          0x80000         0x10000
```

### Flash boot loader

Using `flashcp` from `mtd-utils`.

```shell
flashcp /boot/boot.bin /dev/mtd0
flashcp /boot/u-boot.itb /dev/mtd2
```

### Read eFuse

#### Build PMUFW with `EFUSE_ACCESS` enabled

```diff
Index: embeddedsw/lib/sw_apps/zynqmp_pmufw/src/xpfw_config.h
===================================================================
--- embeddedsw.orig/lib/sw_apps/zynqmp_pmufw/src/xpfw_config.h
+++ embeddedsw/lib/sw_apps/zynqmp_pmufw/src/xpfw_config.h
@@ -208,11 +208,11 @@ extern "C" {
 #endif

 #ifndef ENABLE_SECURE_VAL
-#define        ENABLE_SECURE_VAL                                       (1U)
+#define        ENABLE_SECURE_VAL                                       (0U)
 #endif

 #ifndef ENABLE_EFUSE_ACCESS
-#define ENABLE_EFUSE_ACCESS                                    (0U)
+#define ENABLE_EFUSE_ACCESS                                    (1U)
 #endif

 #ifndef XPU_INTR_DEBUG_PRINT_ENABLE_VAL
```

#### Device DNA

```shell
$ dd if=/sys/bus/nvmem/devices/zynqmp-nvmem0/nvmem of=/tmp/device_dna.bin bs=12 count=1 skip=1
$ xxd /tmp/device_dna.bin
00000000: 4507 a204 c478 5101 0000 0040            E....xQ....@
```
