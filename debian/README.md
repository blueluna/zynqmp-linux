# Debian Root File System

## Quick Start

Build a Debian root file system.

```shell
sudo make
```

## Building Debian

Install debootstrap and statically linked qemu,

```shell
sudo apt-get install -y debootstrap qemu-user-static
```

Create a directory for the root file system.

```shell
mkdir -p arm64
rootfs_dir = `realpath ./arm64`
```

Run the first stage boot strap.

```shell
sudo debootstrap --foreign --arch=arm64 --components=main,contrib,non-free testing ${rootfs_dir} http://ftp.se.debian.org/debian/
```

Copy Qemu to the root file system.

```shell
sudo cp `which qemu-aarch64-static` ${rootfs_dir}/usr/bin/
```

Switch (`chroot`) into the root file system to continue the installation,

```shell
sudo chroot ${rootfs_dir}
```

Run the second stage boot strap

```shell
./debootstrap/debootstrap --second-stage
```

Set the root password

```
passwd
```

### Configure timezone

```shell
dpkg-reconfigure tzdata
```

### Configure locales

```shell
apt-get install -y locales
dpkg-reconfigure locales
```

Install locales `en_GB.UTF-8` and `sv_SE.UTF-8`. Select `en_GB.UTF-8` as default locale.

### Configure hostname

```shell
vi /etc/hostname
```

### Console keyboard layout

```shell
apt-get install console-setup console-setup-linux
```

### Text editor

```shell
apt-get install -y emacs-nox
update-alternatives --config editor
```

### NTP

```shell
apt-get install systemd-timesyncd
```

### Networking

Enable DHCP on ethernet interfaces.

```shell
cp /usr/lib/systemd/network/80-ethernet.network.example /etc/systemd/network/80-ethernet.network
```

### Add user

Before creating any users, change the default shell used for useradd in `/etc/default/useradd`.

```shell
SHELL=/bin/bash
```

Install sudo, to be able to operate as root.

```shell
apt-get install sudo
```

Add a user, <user>, added to some groups,

 * adm, Administrative privileges
 * sudo, Able to use `sudo`
 * dialout, Permission to use serial port.

```
useradd -m -G adm,dialout,sudo <user>
```

Set the password for the user account.

```shell
passwd <user>
```

### Secure shell (SSH) server

```shell
apt-get install -y openssh-server
systemctl enable ssh
```

### Finishing up

Do this late, will break domain name lookup

```
apt-get install systemd-resolved
```

Use archive copy to preserve permissions and such when copying the rootfs,

```shell
cp -a rootfs/* /mount/rootfs
```

## Extras

### log2ram

https://github.com/azlux/log2ram

### Minimal emacs

https://superuser.com/a/1028960
