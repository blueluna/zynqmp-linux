# Bootloader

## Quick Start

```
$ make
```

## U-Boot

Reference: https://lucaceresoli.net/zynqmp-uboot-spl-pmufw-cfg-load/

### Build PMUFW

https://github.com/lucaceresoli/zynqmp-pmufw-binaries

Building the toolchain requires at least, autoconf, texinfo, help2man, gawk, libtool-bin.

#### Building PMUFW

Clone [zynqmp-pmufw-builder](https://github.com/lucaceresoli/zynqmp-pmufw-builder).

```shell
$ git clone --recurse-submodules https://github.com/lucaceresoli/zynqmp-pmufw-builder.git
```

Update crosstool-ng to 1.28.0

```shell
$ cd zynqmp-pmufw-builder
$ cd crosstool-ng
$ git checkout crosstool-ng-1.28.0
$ cd ..
```

Build the toolchain

```shell
$ ./build.sh toolchain
```

Build the PMUFW, with error module enabled

```shell
$ CFLAGS="-DENABLE_EM" ./build.sh pmufw-build
```

### Build PMU configuration object

Using Xilinx Vitis, create a FSBL project using the platform (XSA) files. In the generated project, find the `pm_cfg_obj.c` file.

Clone `embeddedsw` and change to a appropriate release tag.

```shell
git clone https://github.com/Xilinx/embeddedsw.git
git checkout xilinx-v2022.1
```

Compile the configuration object source into a object file using the embeddedsw library.

```shell
export EMBEDDED_SW=`realpath <path to embeddedsw>`
aarch64-linux-gnu-gcc -c pm_cfg_obj.c -I ${EMBEDDED_SW}/lib/bsp/standalone/src/common/ -I ${EMBEDDED_SW}/lib/sw_services/xilpm/src/zynqmp/client/common/
```

Generate a binary configuration object using objcopy.

```shell
aarch64-linux-gnu-objcopy -O binary pm_cfg_obj.o pmu_obj.bin
```

### Arm Trusted Firmware (ATF)

Get a aarch64-none-elf toolchain, like arm-gnu.

From,
https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads

Download `arm-gnu-toolchain-<version>-x86_64-aarch64-none-elf.tar.xz`.

Extract the toolchain,
```shell
mkdir -p arm-toolchain
tar -C arm-toolchain --strip-components=1 -xf /home/erik/Downloads/arm-gnu-toolchain-11.3.rel1-x86_64-aarch64-none-elf.tar.xz
```

```shell
git clone https://github.com/Xilinx/arm-trusted-firmware.git
cd arm-trusted-firmware
git checkout xilinx-v2022.1
```

```shell
PATH=${PATH}:<path to arm-toolchain/bin> make CROSS_COMPILE=aarch64-none-elf- PLAT=zynqmp RESET_TO_BL31=1 bl31
```

The result is `build/zynqmp/release/bl31.bin`.

### Build U-Boot

Download and extract U-Boot.

```shell
curl -JLO https://github.com/u-boot/u-boot/archive/refs/tags/v2022.07.tar.gz
tar -xf u-boot-2022.07.tar.gz
```

#### Custom Board

If the board doesn't have a directory in `board/xilinx/zynqmp` of U-Boot, a new directory will have to be created.

```shell
mkdir -p board/xilinx/zynqmp/<my_board>
```

From the Xilinx platform (XSA) archive, extract `psu_init_gpl.h` and `psu_init_gpl.c`.

```shell
mkdir -p xsa_files
unzip -d xsa_files <my_board>.xsa
```

From the u-boot source directory,
```shell
./tools/zynqmp_psu_init_minimize.sh path/to/xsa_files board/xilinx/zynqmp/my_board/
```

Create a device tree for the board, it is possible to build a full device tree with Xilinx tools and take inspiration from that.

Put the device tree source in `arch/arm/dts` with the name `<my_board>.dts`.
Add `<my_board>.dts` the the Makefile in `arch/arm/dts/Makefile`.

Ensure that the board directory `board/xilinx/zynqmp/<my_board>` and the device tree file name is the same `<my_board>.dts`. The U-boot make system will use the `DEFAULT_DEVICE_TREE` variable to find the initialisation code.

#### Build U-Boot

```shell
CROSS_COMPILE=aarch64-linux-gnu- ARCH=aarch64 make xilinx_zynqmp_virt_defconfig
```

Add following to the U-Boot build configuration,

 * PMU firmware path. ARM architecture > PMU firmware (`PMUFW_INIT_FILE`).
 * PM configuration object path. ARM architecture > PMU firmware configuration object to load at runtime by SPL (`ZYNQMP_SPL_PM_CFG_OBJ_FILE`)

Change the default device tree to `<my_board>` in Device Tree Control > Default Device Tree for DT control (`DEFAULT_DEVICE_TREE`).

Build U-boot. Provide the path to ATF (TF-A) with the `BL31` environment variable.

```shell
BL31=/path/to/bl31.bin CROSS_COMPILE=aarch64-linux-gnu- ARCH=aarch64 make -j 
```

### U-boot script

```shell
u-boot/tools/mkimage -A arm64 -O linux -T script -C none -a 0 -e 0 -n "te0802 boot" -d boot.script boot.scr
```

### Extlinux

On the boot partition, create a directory `extlinux`.

```shell
mkdir -p extlinux
```

Create a extlinux configuration in the directory, `extlinux/extlinux.conf`.

```
label linux
    kernel /Image
    fdt /<my_board>.dtb
    append rootwait earlycon clk_ignore_unused consoleblank=0 root=/dev/mmcblk0p2 rootfstype=ext4 rw rootwait
```
