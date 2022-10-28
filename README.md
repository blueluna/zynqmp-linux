# Boot TE0802-02

Booting Trenz Electronic TE0802-02 with as few Xilinx tools possible.

## U-Boot

Reference: https://lucaceresoli.net/zynqmp-uboot-spl-pmufw-cfg-load/

### Build PMUFW

https://github.com/lucaceresoli/zynqmp-pmufw-binaries

### Build PMU configuration object

Using Xilinx Vitis, create a FSBL project using the platform (XSA) files. In the generated project, find the `pm_cfg_obj.c` file.

Clone `embeddedsw` and change to a appropriate release tag.

```
git clone https://github.com/Xilinx/embeddedsw.git
git checkout xilinx-v2022.1
```

Compile the configuration object source into a object file using the embeddedsw library.

```
export EMBEDDED_SW=`realpath <path to embeddedsw>`
aarch64-linux-gnu-gcc -c pm_cfg_obj.c -I ${EMBEDDED_SW}/lib/bsp/standalone/src/common/ -I ${EMBEDDED_SW}/lib/sw_services/xilpm/src/zynqmp/client/common/
```

Generate a binary configuration object using objcopy.

```
aarch64-linux-gnu-objcopy -O binary pm_cfg_obj.o pmu_obj.bin
```

### Arm Trusted Firmware (ATF)

Get a aarch64-none-elf toolchain, like arm-gnu.

From,
https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads

Download `arm-gnu-toolchain-<version>-x86_64-aarch64-none-elf.tar.xz`.

Extract the toolchain,
```
mkdir -p arm-toolchain
tar -C arm-toolchain --strip-components=1 -xf /home/erik/Downloads/arm-gnu-toolchain-11.3.rel1-x86_64-aarch64-none-elf.tar.xz
```

```
git clone https://github.com/Xilinx/arm-trusted-firmware.git
cd arm-trusted-firmware
git checkout xilinx-v2022.1
```

```
PATH=${PATH}:<path to arm-toolchain/bin> make CROSS_COMPILE=aarch64-none-elf- PLAT=zynqmp RESET_TO_BL31=1 bl31
```

The result is `build/zynqmp/release/bl31.bin`.

### Build U-Boot

Download and extract U-Boot.

```
curl -JLO https://github.com/u-boot/u-boot/archive/refs/tags/v2022.07.tar.gz
tar -xf u-boot-2022.07.tar.gz
```

#### Custom Board

If the board doesn't have a directory in `board/xilinx/zynqmp` of U-Boot, a new directory will have to be created.

```
mkdir -p board/xilinx/zynqmp/<my_board>
```

From the Xilinx platform (XSA) archive, extract `psu_init_gpl.h` and `psu_init_gpl.c`.

```
mkdir -p xsa_files
unzip -d xsa_files <my_board>.xsa
```

Copy these files to the created directory.

```
cp xsa_files/psu_init_gpl.h xsa_files/psu_init_gpl.c board/xilinx/zynqmp/<my_board>
```

Create a device tree for the board, it is possible to build a full device tree with Xilinx tools and take inspiration from that.

Put the device tree source in `arch/arm/dts` with the name `<my_board>.dts`.
Add `<my_board>.dts` the the Makefile in `arch/arm/dts/Makefile`.

Ensure that the board directory `board/xilinx/zynqmp/<my_board>` and the device tree file name is the same `<my_board>.dts`. The U-boot make system will use the `DEFAULT_DEVICE_TREE` variable to find the initialisation code.

#### Build U-Boot

```
CROSS_COMPILE=aarch64-linux-gnu- ARCH=aarch64 make xilinx_zynqmp_virt_defconfig
```

Add following to the U-Boot build configuration,

 * PMU firmware path. ARM architecture > PMU firmware (`PMUFW_INIT_FILE`).
 * PM configuration object path. ARM architecture > PMU firmware configuration object to load at runtime by SPL (`ZYNQMP_SPL_PM_CFG_OBJ_FILE`)

Change the default device tree to `<my_board>` in Device Tree Control > Default Device Tree for DT control (`DEFAULT_DEVICE_TREE`).

Build U-boot. Provide the path to ATF (TF-A) with the `BL31` environment variable.

```
BL31=/path/to/bl31.bin CROSS_COMPILE=aarch64-linux-gnu- ARCH=aarch64 make -j 
```

### U-boot script

```
u-boot/tools/mkimage -A arm64 -O linux -T script -C none -a 0 -e 0 -n "te0802 boot" -d boot.script boot.scr
```

### Extlinux

On the boot partition, create a directory `extlinux`.

```
mkdir -p extlinux
```

Create a extlinux configuration in the directory, `extlinux/extlinux.conf`.

```
label linux
    kernel /Image
    fdt /<my_board>.dtb
    append rootwait earlycon clk_ignore_unused consoleblank=0 root=/dev/mmcblk0p2 rootfstype=ext4 rw rootwait
```

## Linux kernel

```
git clone https://github.com/Xilinx/linux-xlnx.git
cd linux-xlnx
git checkout xilinx-v2022.1
```

```
CROSS_COMPILE=aarch64-linux-gnu- make defconfig ARCH=arm64
CROSS_COMPILE=aarch64-linux-gnu- make menuconfig ARCH=arm64
CROSS_COMPILE=aarch64-linux-gnu- make -j6 ARCH=arm64
```

## Build Debian rootfs

Install debootstrap and statically linked qemu,

```
sudo apt-get install -y debootstrap qemu-user-static
```

Create a directory for the root file system.

```
mkdir -p arm64
rootfs_dir = `realpath ./arm64`
```

Run the first stage boot strap.

```
sudo debootstrap --foreign --arch=arm64 --components=main,contrib,non-free testing ${rootfs_dir} http://ftp.se.debian.org/debian/
```

Copy Qemu to the root file system.

```
sudo cp `which qemu-aarch64-static` ${rootfs_dir}/usr/bin/
```

Switch (`chroot`) into the root file system to continue the installation,

```
sudo chroot ${rootfs_dir}
```

Run the second stage boot strap

```
./debootstrap/debootstrap --second-stage
```

Set the root password

```
passwd
```

### Configure timezone

```
dpkg-reconfigure tzdata
```

### Configure locales

```
apt-get install -y locales
dpkg-reconfigure locales
```

Install locales `en_GB.UTF-8` and `sv_SE.UTF-8`. Select `en_GB.UTF-8` as default locale.

### Configure hostname

```
vi /etc/hostname
```

### Console keyboard layout

```
apt-get install console-setup console-setup-linux
```

### Text editor

```
apt-get install -y emacs-nox
update-alternatives --config editor
```

### NTP

```
apt-get install systemd-timesyncd
```

### Networking

Enable DHCP on ethernet interfaces.

```
cp /usr/lib/systemd/network/80-ethernet.network.example /etc/systemd/network/80-ethernet.network
```

### Add user

Before creating any users, change the default shell used for useradd in `/etc/default/useradd`.

```
SHELL=/bin/bash
```

Install sudo, to be able to operate as root.

```
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

```
passwd <user>
```

### Secure shell (SSH) server

```
apt-get install -y openssh-server
systemctl enable ssh
```

### Finishing up

Do this late, will break domain name lookup

```
apt-get install systemd-resolved
```

## Issues

### Ping permissions

Cannot ping as a regular user.

```
ping: icmp open socket: Operation not permitted
```

Need to set network capabilities.

```
setcap cap_net_raw=ep $(which ping)
```

### Reboot issue

```
Received exception
MSR: 0x200, EAR: 0xFFE00001, EDR: 0x0, ESR: 0x4C4
```

https://github.com/Xilinx/embeddedsw/issues/172


### sudo permissions

```
sudo: /usr/bin/sudo must be owned by uid 0 and have the setuid bit set
```

```
chmod 4755 /usr/bin/sudo
```
