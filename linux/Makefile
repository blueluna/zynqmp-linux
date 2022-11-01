# SPDX-License-Identifier: MIT
# Linux kernel for TE0802-02
#
# Author: Erik Banvik <erik.public@gmail.com>

include ../constants.makefile

linux_dir=linux-xlnx-$(xilinx_tag)
linux_archive=$(linux_dir).tar.gz
linux_url=https://github.com/Xilinx/linux-xlnx/archive/refs/tags/$(xilinx_tag).tar.gz
linux_unpacked=$(linux_dir)/Makefile
linux_patches_dir=$(linux_dir)/patches
linux_configured=$(linux_dir)/.configured
linux_built=$(linux_dir)/.built

boot_dir=$(linux_dir)/arch/arm64/boot
device_tree_dir=$(boot_dir)/dts/xilinx
dts_destination=$(device_tree_dir)/$(device_tree_source)
dts_makefile=$(device_tree_dir)/Makefile

linux_modules_dir=$(output_dir)/modules
linux_modules_installed=$(linux_modules_dir)/.installed

linux_headers_dir=$(output_dir)/headers
linux_headers_installed=$(linux_headers_dir)/.installed

linux_image_output=$(output_dir)/Image

all: $(linux_image_output) $(linux_modules_installed) $(linux_headers_installed)

.PHONY: clean

include ../common.makefile

CROSS_COMPILE=$(aarch64_linux_cross)

$(dts_destination): $(linux_unpacked) $(device_tree_source_path)
	cp $(device_tree_source_path) $(dts_destination)
	$(shell echo 'dtb-$$(CONFIG_ARCH_ZYNQMP) += $(device_tree_binary)' >> $(dts_makefile))

$(linux_archive):
	curl -JLO $(linux_url)

$(linux_unpacked): $(linux_archive)
	tar -xf $<
	touch $@

$(linux_modules_dir):
	mkdir -p $@
	touch $@

$(linux_headers_dir):
	mkdir -p $@
	touch $@

$(linux_configured): $(dts_destination) $(aarch64_linux_marker)
	cp te0802_02_defconfig $(linux_dir)/arch/arm64/configs/
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(linux_dir) te0802_02_defconfig ARCH=arm64
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(linux_dir) oldconfig ARCH=arm64
	touch $@

$(linux_built): $(linux_configured) $(aarch64_linux_marker)
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -j$(num_jobs) -C $(linux_dir) ARCH=arm64
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -j$(num_jobs) -C $(linux_dir) modules ARCH=arm64
	touch $@

$(linux_modules_installed): $(linux_built) $(aarch64_linux_marker)
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -j$(num_jobs) -C $(linux_dir) modules_install ARCH=arm64 INSTALL_MOD_PATH=$(abspath $(linux_modules_dir))
	touch $@

$(linux_headers_installed): $(linux_built) $(aarch64_linux_marker)
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -j$(num_jobs) -C $(linux_dir) headers_install ARCH=arm64 INSTALL_HDR_PATH=$(abspath $(linux_headers_dir))
	touch $@

$(linux_image_output): $(linux_built)
	cp $(boot_dir)/Image.gz $(linux_image_output)

clean:
	rm -rf $(linux_dir) $(linux_modules_dir) $(linux_headers_dir)
