# SPDX-License-Identifier: MIT
# Linux kernel for ZynqMP
#
# Author: Erik Banvik <erik.public@gmail.com>

include ../constants.makefile

board_dir_linux=$(board_dir)/linux

#linux_version=6.2
#linux_version_sublevel=8

#linux_version=6.12
#linux_version_sublevel=57

#linux_version=6.17
#linux_version_sublevel=7

linux_version=6.18
linux_version_sublevel=0

linux_version_long=$(linux_version).$(linux_version_sublevel)

ifeq ($(linux_version_sublevel),0)
	linux_name=linux-$(linux_version)
else
	linux_name=linux-$(linux_version_long)
endif

linux_dir=$(abspath $(linux_name))
linux_archive=$(linux_name).tar.xz
linux_url=https://cdn.kernel.org/pub/linux/kernel/v6.x/$(linux_archive)
linux_unpacked=$(linux_dir)/Makefile
linux_patches_dir=$(linux_dir)/patches
linux_config=$(linux_dir)/.config
linux_built=$(linux_dir)/.built

linux_boot_dir=$(linux_dir)/arch/arm64/boot
linux_device_tree_dir=$(linux_boot_dir)/dts/xilinx
linux_dts_destination=$(linux_device_tree_dir)/$(device_tree_source)
linux_dts_makefile=$(linux_device_tree_dir)/Makefile

linux_image=Image.lzma
linux_output_dir=$(output_dir)/$(linux_name)
linux_modules_dir=$(linux_output_dir)/modules
linux_output_image=$(linux_output_dir)/Image
linux_output_modules_dir=$(linux_modules_dir)/lib/modules/$(linux_version_long)
linux_output_modules=$(linux_output_modules_dir)/modules.builtin
linux_output_modules_archive=$(linux_modules_dir)/$(linux_version_long).tar.xz
linux_binary_device_tree=$(linux_device_tree_dir)/$(device_tree_binary)
linux_headers_dir=$(linux_output_dir)/headers
linux_headers_installed=$(linux_headers_dir)/.installed

dtbocfg_version=0.1.1
dtbocfg_name=dtbocfg-$(dtbocfg_version)
dtbocfg_dir=$(abspath $(dtbocfg_name))
dtbocfg_archive=$(dtbocfg_dir).tar.gz
dtbocfg_url=https://github.com/ikwzm/dtbocfg/archive/refs/tags/v${dtbocfg_version}.tar.gz
dtbocfg_unpacked=$(dtbocfg_dir)/Makefile
dtbocfg_built=$(dtbocfg_dir)/.built
dtbocfg_installed=$(linux_output_modules_dir)/updates/dtbocfg.ko

default: mainline

.PHONY: clean

include ../common.makefile

CROSS_COMPILE=$(aarch64_linux_cross)

$(linux_dts_destination): $(linux_unpacked) $(device_tree_source_path)
	cp $(device_tree_source_path) $(linux_dts_destination)
	$(shell echo 'dtb-$$(CONFIG_ARCH_ZYNQMP) += $(device_tree_binary)' >> $(linux_dts_makefile))

$(linux_archive):
	curl -JLO $(linux_url)

$(linux_unpacked): $(linux_archive)
	tar -xf $<
	touch $@

$(linux_output_dir):
	mkdir -p $@
	touch $@

$(linux_modules_dir):
	mkdir -p $@
	touch $@

$(linux_headers_dir):
	mkdir -p $@
	touch $@

$(linux_config): $(linux_dts_destination) $(aarch64_linux_marker)
	cp $(board_dir_linux)/$(linux_version)/$(kernel_configuration_name) $(linux_dir)/arch/arm64/configs/
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(linux_dir) $(kernel_configuration_name) ARCH=arm64
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(linux_dir) oldconfig ARCH=arm64
	touch $@

$(linux_built): $(linux_config) $(aarch64_linux_marker)
	DTC_FLAGS="-@" CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -j$(num_jobs) -C $(linux_dir) ARCH=arm64
	DTC_FLAGS="-@" CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -j$(num_jobs) -C $(linux_dir) ARCH=arm64 $(linux_image)
	DTC_FLAGS="-@" CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -j$(num_jobs) -C $(linux_dir) modules ARCH=arm64
	touch $@

$(dtbocfg_archive):
	curl -JLO $(dtbocfg_url)

$(dtbocfg_unpacked): $(dtbocfg_archive)
	tar -xf $<
	touch $@

$(dtbocfg_built): $(dtbocfg_unpacked) $(linux_built)
	cd $(dtbocfg_dir) && CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -j$(num_jobs) ARCH=arm64 KERNEL_SRC=$(linux_dir)
	touch $@

$(linux_output_image): $(linux_built) $(linux_output_dir)
	cp $(linux_boot_dir)/$(linux_image) $(linux_output_image)

$(linux_binary_device_tree): $(linux_built) $(linux_output_dir)
	cp $(linux_binary_device_tree) $(linux_output_dir)

$(linux_output_modules): $(linux_built) $(linux_modules_dir)
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(linux_dir) modules_install ARCH=arm64 INSTALL_MOD_PATH=$(linux_modules_dir)

$(linux_output_modules_archive): $(linux_output_modules) $(dtbocfg_installed)
	tar -I xz -cf $@ -C $(linux_output_modules_dir) .

$(linux_headers_installed): $(linux_built) $(linux_headers_dir)
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(linux_dir) headers_install ARCH=arm64 INSTALL_HDR_PATH=$(linux_headers_dir)
	touch $@

$(dtbocfg_installed): $(linux_output_modules) $(dtbocfg_built) $(linux_modules_dir)
	cd $(dtbocfg_dir) && CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) modules_install ARCH=arm64 KERNEL_SRC=$(linux_dir) INSTALL_MOD_PATH=$(linux_modules_dir)

mainline: $(linux_output_image) $(linux_binary_device_tree) $(linux_output_modules) $(linux_output_modules_archive) $(dtbocfg_installed) $(linux_headers_installed)

config:
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -j$(num_jobs) -C $(linux_dir) ARCH=arm64 menuconfig

saveconfig:
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -j$(num_jobs) -C $(linux_dir) ARCH=arm64 savedefconfig
	cp $(linux_dir)/defconfig $(board_dir_linux)/$(linux_version)/$(kernel_configuration_name)

clean:
	rm -rf $(xilinx_linux_dir) $(linux_dir) $(linux_modules_dir) $(linux_headers_dir) $(linux_output_dir) $(dtbocfg_dir)
