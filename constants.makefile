# SPDX-License-Identifier: MIT
# Common constants
#
# Author: Erik Banvik <erik.public@gmail.com>

base_dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

num_processors=$(shell nproc)
num_jobs=$(shell expr $(num_processors) - 2)

V?=0
ifeq ($(V),1)
  Q=
else
  Q=@
  MAKEFLAGS += -s
endif

TE0802_02_NAME=te0802-02
MYIR_FZ3_NAME=myir-fz3

board=

ifeq ($(board),$(TE0802_02_NAME))
  short_name=$(TE0802_02_NAME)
  kernel_configuration_name=te0802_02_defconfig
else ifeq ($(board),$(MYIR_FZ3_NAME))
  short_name=$(MYIR_FZ3_NAME)
  kernel_configuration_name=myir_fz3_defconfig
endif

board_dir=$(base_dir)$(short_name)
board_name=zynqmp-$(short_name)


download_dir=$(base_dir)downloads
output_dir=$(board_dir)/output

xilinx_version=v2022.2
xilinx_tag=xilinx-$(xilinx_version)

arm_gcc_version=11.2-2022.02

aarch64_none_triplet=aarch64-none-elf
aarch64_none_dir=gcc-arm-$(arm_gcc_version)-x86_64-$(aarch64_none_triplet)
aarch64_none_archive=$(aarch64_none_dir).tar.xz
aarch64_none_archive_path=$(download_dir)/$(aarch64_none_archive)
aarch64_none_url=https://developer.arm.com/-/media/Files/downloads/gnu/$(arm_gcc_version)/binrel/$(aarch64_none_archive)
aarch64_none_bin=$(base_dir)$(aarch64_none_dir)/bin
aarch64_none_cross=$(aarch64_none_bin)/$(aarch64_none_triplet)-
aarch64_none_gcc=$(aarch64_none_cross)gcc
aarch64_none_marker=$(base_dir)$(aarch64_none_dir)/.unpacked

aarch64_linux_triplet=aarch64-none-linux-gnu
aarch64_linux_dir=gcc-arm-$(arm_gcc_version)-x86_64-$(aarch64_linux_triplet)
aarch64_linux_archive=$(aarch64_linux_dir).tar.xz
aarch64_linux_archive_path=$(download_dir)/$(aarch64_linux_archive)
aarch64_linux_url=https://developer.arm.com/-/media/Files/downloads/gnu/$(arm_gcc_version)/binrel/$(aarch64_linux_archive)
aarch64_linux_bin=$(base_dir)$(aarch64_linux_dir)/bin
aarch64_linux_cross=$(aarch64_linux_bin)/$(aarch64_linux_triplet)-
aarch64_linux_gcc=$(aarch64_linux_cross)gcc
aarch64_linux_marker=$(base_dir)$(aarch64_linux_dir)/.unpacked

device_tree_source=$(board_name).dts
device_tree_binary=$(board_name).dtb
device_tree_source_path=$(board_dir)/$(device_tree_source)

hardware_definition=system.xsa
xsa_source=$(board_dir)/$(hardware_definition)

rootfs_dir=$(base_dir)rootfs
rootfs_first_stage=$(rootfs_dir)/.first_stage
rootfs_second_stage=$(rootfs_dir)/.second_stage
rootfs_done=$(rootfs_dir)/.done
