# Arm64 om Linux distributions

## Gentoo

Inspired by [Quick Installation Checklist](https://wiki.gentoo.org/wiki/Quick_Installation_Checklist).

[Download a stage 3 archive](https://www.gentoo.org/downloads/) and extract to a root file system.

```shell
$ sudo tar -xf stage3-arm64-systemd-....tar.xz -C /run/media/user/rootfs/
```

chroot in the file system

```shell
$ sudo chroot /run/media/user/rootfs/
```

Ensure that root is readable and executable
```shell
# chmod 755 /
```

Create a password for root
```shell
# passwd
```

Create a user
```shell
# useradd -g users -G adm,wheel,portage,audio,video,usb,cdrom -m username
# passwd username
```

