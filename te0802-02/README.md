# Trenz-Electronic TE0802-02

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
