# SPDX-License-Identifier: MIT
# Linux kernel for TE0802-02
#
# Author: Erik Banvik <erik.public@gmail.com>

include ../constants.makefile

board_dir_linux=$(board_dir)/linux

xilinx_linux_dir=linux-xlnx-$(xilinx_tag)
xilinx_linux_archive=$(xilinx_linux_dir).tar.gz
xilinx_linux_url=https://github.com/Xilinx/linux-xlnx/archive/refs/tags/$(xilinx_tag).tar.gz
xilinx_linux_unpacked=$(xilinx_linux_dir)/Makefile
xilinx_linux_patches_dir=$(xilinx_linux_dir)/patches
xilinx_linux_configured=$(xilinx_linux_dir)/.configured
xilinx_linux_built=$(xilinx_linux_dir)/.built

xilinx_boot_dir=$(xilinx_linux_dir)/arch/arm64/boot
xilinx_device_tree_dir=$(xilinx_boot_dir)/dts/xilinx
xilinx_dts_destination=$(xilinx_device_tree_dir)/$(device_tree_source)
xilinx_dts_makefile=$(xilinx_device_tree_dir)/Makefile

mainline_linux_version=6.12.57
mainline_linux_dir=linux-$(mainline_linux_version)
mainline_linux_archive=$(mainline_linux_dir).tar.xz
mainline_linux_url=https://cdn.kernel.org/pub/linux/kernel/v6.x/$(mainline_linux_archive)
mainline_linux_unpacked=$(mainline_linux_dir)/Makefile
mainline_linux_patches_dir=$(mainline_linux_dir)/patches
mainline_linux_configured=$(mainline_linux_dir)/.configured
mainline_linux_built=$(mainline_linux_dir)/.built

mainline_boot_dir=$(mainline_linux_dir)/arch/arm64/boot
mainline_device_tree_dir=$(mainline_boot_dir)/dts/xilinx
mainline_dts_destination=$(mainline_device_tree_dir)/$(device_tree_source)
mainline_dts_makefile=$(mainline_device_tree_dir)/Makefile

dtbocfg_version=0.1.1
dtbocfg_dir=dtbocfg-$(dtbocfg_version)
dtbocfg_archive=dtbocfg-$(dtbocfg_version).tar.gz
dtbocfg_url=https://github.com/ikwzm/dtbocfg/archive/refs/tags/v${dtbocfg_version}.tar.gz
dtbocfg_unpacked=$(dtbocfg_dir)/Makefile
dtbocfg_built=$(dtbocfg_dir)/.built
dtbocfg_installed=$(dtbocfg_dir)/.installed

linux_modules_dir=$(output_dir)/modules
linux_modules_installed=$(linux_modules_dir)/.installed

linux_headers_dir=$(output_dir)/headers
linux_headers_installed=$(linux_headers_dir)/.installed

linux_image_output=$(output_dir)/Image

mainline_linux_output_dir=$(output_dir)/$(mainline_linux_dir)
mainline_linux_modules_dir=$(rootfs_dir)
mainline_linux_output_image=$(mainline_linux_output_dir)/Image
mainline_linux_output_modules=$(mainline_linux_modules_dir)/lib/modules/$(mainline_linux_version)//modules.builtin

default: mainline

.PHONY: clean

include ../common.makefile

CROSS_COMPILE=$(aarch64_linux_cross)

$(linux_modules_dir):
	mkdir -p $@
	touch $@

$(linux_headers_dir):
	mkdir -p $@
	touch $@

$(xilinx_dts_destination): $(xilinx_linux_unpacked) $(device_tree_source_path)
	cp $(device_tree_source_path) $(xilinx_dts_destination)
	$(shell echo 'dtb-$$(CONFIG_ARCH_ZYNQMP) += $(device_tree_binary)' >> $(xilinx_dts_makefile))

$(xilinx_linux_archive):
	curl -JLO $(xilinx_linux_url)

$(xilinx_linux_unpacked): $(xilinx_linux_archive)
	tar -xf $<
	touch $@

$(xilinx_linux_configured): $(xilinx_dts_destination) $(aarch64_linux_marker)
	cp $(kernel_configuration_name) $(xilinx_linux_dir)/arch/arm64/configs/
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(xilinx_linux_dir) $(kernel_configuration_name) ARCH=arm64
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(xilinx_linux_dir) oldconfig ARCH=arm64
	touch $@

$(xilinx_linux_built): $(xilinx_linux_configured) $(aarch64_linux_marker)
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -j$(num_jobs) -C $(xilinx_linux_dir) ARCH=arm64
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -j$(num_jobs) -C $(xilinx_linux_dir) modules ARCH=arm64
	touch $@

$(linux_modules_installed): $(xilinx_linux_built) $(aarch64_linux_marker)
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -j$(num_jobs) -C $(xilinx_linux_dir) modules_install ARCH=arm64 INSTALL_MOD_PATH=$(abspath $(linux_modules_dir))
	touch $@

$(linux_headers_installed): $(xilinx_linux_built) $(aarch64_linux_marker)
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -j$(num_jobs) -C $(xilinx_linux_dir) headers_install ARCH=arm64 INSTALL_HDR_PATH=$(abspath $(linux_headers_dir))
	touch $@

$(linux_image_output): $(xilinx_linux_built) $(output_dir)
	cp $(xilinx_boot_dir)/Image.gz $(linux_image_output)

$(mainline_dts_destination): $(mainline_linux_unpacked) $(device_tree_source_path)
	cp $(device_tree_source_path) $(mainline_dts_destination)
	$(shell echo 'dtb-$$(CONFIG_ARCH_ZYNQMP) += $(device_tree_binary)' >> $(mainline_dts_makefile))

$(mainline_linux_archive):
	curl -JLO $(mainline_linux_url)

$(mainline_linux_unpacked): $(mainline_linux_archive)
	tar -xf $<
	touch $@

$(mainline_linux_output_dir):
	mkdir -p $@
	touch $@

$(mainline_linux_configured): $(mainline_dts_destination) $(aarch64_linux_marker)
	cp $(board_dir_linux)/$(mainline_linux_version)/$(kernel_configuration_name) $(mainline_linux_dir)/arch/arm64/configs/
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(mainline_linux_dir) $(kernel_configuration_name) ARCH=arm64
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(mainline_linux_dir) oldconfig ARCH=arm64
	touch $@

$(mainline_linux_built): $(mainline_linux_configured) $(aarch64_linux_marker)
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -j$(num_jobs) -C $(mainline_linux_dir) ARCH=arm64
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -j$(num_jobs) -C $(mainline_linux_dir) modules ARCH=arm64
	touch $@

$(dtbocfg_archive):
	curl -JLO $(dtbocfg_url)

$(dtbocfg_unpacked): $(dtbocfg_archive)
	tar -xf $<
	touch $@

$(dtbocfg_built): $(dtbocfg_unpacked) $(mainline_linux_built)
	cd $(dtbocfg_dir) && CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -j$(num_jobs) ARCH=arm64 KERNEL_SRC=$(abspath $(mainline_linux_dir))
	touch $@

$(mainline_linux_output_image): $(mainline_linux_built) $(mainline_linux_output_dir)
	cp $(mainline_boot_dir)/Image.gz $(mainline_linux_output_image)

$(mainline_linux_output_modules): $(mainline_linux_built) $(mainline_linux_modules_dir)
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(mainline_linux_dir) modules_install ARCH=arm64 INSTALL_MOD_PATH=$(abspath $(mainline_linux_modules_dir))

$(dtbocfg_installed): $(mainline_linux_output_modules) $(dtbocfg_built)
	cd $(dtbocfg_dir) && CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) modules_install ARCH=arm64 KERNEL_SRC=$(abspath $(mainline_linux_dir)) INSTALL_MOD_PATH=$(abspath $(mainline_linux_modules_dir))

mainline: $(mainline_linux_output_image) $(dtbocfg_built)

xilinx: $(xilinx_linux_built)

install_modules: $(mainline_linux_output_modules) $(dtbocfg_installed)

config:
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -j$(num_jobs) -C $(mainline_linux_dir) ARCH=arm64 menuconfig

clean:
	rm -rf $(xilinx_linux_dir) $(mainline_linux_dir) $(linux_modules_dir) $(linux_headers_dir) $(mainline_linux_output_dir) $(dtbocfg_dir)
