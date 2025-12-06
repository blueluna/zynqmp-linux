# Trenz-Electronic TE0802-02

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
 - [x] NVMe
 - [x] I^2^C EEPROM
 - [x] QSPI flash
 - [ ] DisplayPort Video
 - [ ] DisplayPort Audio
 - [x] PL

## Install Root File System on NVMe

After booting with SD-card. Ensure that nvme and btrfs is build into the kernel.

Install `btrfs-progs`, `parted` and `rsync`.

Create a partition table

```shell
parted -s /dev/nvme0n1 mklabel gpt
```

Create a btrfs partition

```shell
parted -s /dev/nvme0n1 mkpart primary btrfs 1MiB 100%
```

Create a btrfs filesystem on the partition

```shell
mkfs.btrfs -f /dev/nvme0n1p1
```

Mount and copy the rootfs

```shell
mkdir -p /media/nvme
mount /dev/nvme0n1p1 /media/nvme
rsync -avrltD --exclude-from=exclude.txt / /media/nvme
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

Update `extlinux.conf` to use the NVMe rootfs,

```
root=/dev/nvme0n1p1 rootfstype=btrfs
```

## QSPI boot

boot-script.txt
```
f read $kernel_addr_r 0x0800000 0x0a00000
sf read $fdt_addr_r 0x0700000 0x0100000
env set bootargs 'rootwait earlycon clk_ignore_unused consoleblank=0 cma=128M uio_pdrv_genirq.of_id=generic-uio root=/dev/nvme0n1p1 rootfstype=btrfs rw'
booti $kernel_addr_r - $fdt_addr_r
```

```
$ ./u-boot/u-boot-2022.10/tools/mkimage -A arm -T script -d te0802-02/u-boot/boot-script.txt te0802-02/u-boot/boot.scr
```

```
$ cat /proc/mtd
dev:    size   erasesize  name
mtd0: 00100000 00001000 "fsbl"
mtd1: 00100000 00001000 "ssbl_config"
mtd2: 00400000 00001000 "ssbl"
mtd3: 00100000 00001000 "ssbl_script"
mtd4: 00100000 00001000 "device-tree"
mtd5: 00a00000 00001000 "linux"
mtd6: 00e00000 00001000 "data"
```

```
# flashcp boot.bin /dev/mtd0
# flashcp u-boot.itb /dev/mtd2
# flashcp boot.scr /dev/mtd3
# flashcp zynqmp-te0802-02.dtb /dev/mtd4
# flashcp Image /dev/mtd5
```
