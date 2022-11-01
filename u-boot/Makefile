# SPDX-License-Identifier: MIT
# Bootloader for TE0802-02
#
# Author: Erik Banvik <erik.public@gmail.com>

xilinx_version=v2022.1

embeddedsw_dir=embeddedsw-xilinx_$(xilinx_version)
embeddedsw_url=https://github.com/Xilinx/embeddedsw/archive/refs/tags/xilinx_$(xilinx_version).tar.gz
embeddedsw_archive=$(embeddedsw_dir).tar.gz
embeddedsw_sources=$(embeddedsw_dir)/.sources

pmufw=pmufw-v2022.1.bin
pmufw_url=https://github.com/lucaceresoli/zynqmp-pmufw-binaries/raw/master/bin/$(pmufw)

pmu_obj_obj=pm_cfg_obj.o
pmu_obj_src=$(pmu_obj_obj:%.o=%.c)
pmu_obj=pmu_obj.bin

atf_url=https://github.com/Xilinx/arm-trusted-firmware/archive/refs/tags/xilinx-$(xilinx_version).tar.gz
atf_dir=arm-trusted-firmware-xilinx-$(xilinx_version)
atf_archive=$(atf_dir).tar.gz
atf_makefile=$(atf_dir)/Makefile
atf_bin=$(atf_dir)/build/zynqmp/release/bl31.bin

u_boot_version=2022.10
u_boot_dir=u-boot-$(u_boot_version)
u_boot_archive=$(u_boot_dir).tar.bz2
u_boot_url=https://ftp.denx.de/pub/u-boot/$(u_boot_archive)
u_boot_unpacked=$(u_boot_dir)/Makefile
u_boot_patches_dir=$(u_boot_dir)/patches
u_boot_patched=$(u_boot_dir)/.patched
u_boot_built=$(u_boot_dir)/.built

board_name=zynqmp-te0802-02

device_tree_source=$(board_name).dts
dts_source=$(abspath ../$(device_tree_source))
dts_destination=$(u_boot_dir)/arch/arm/dts/$(device_tree_source)

hardware_definition=top_wrapper.xsa
xsa_source=$(abspath ../$(hardware_definition))
xsa_dir=xsa
psu_init_file=psu_init_gpl
psu_init_header=$(xsa_dir)/$(psu_init_file).h
psu_init_source=$(xsa_dir)/$(psu_init_file).c
psu_init_installed=$(u_boot_board_dir)/$(psu_init_file).c

u_boot_board_dir=$(u_boot_dir)/board/xilinx/zynqmp/$(board_name)

u_boot_current_config=$(u_boot_dir)/.config

num_processors=$(shell nproc)
num_jobs=$(shell expr $(num_processors) - 2)

all: $(u_boot_built)

.PHONY: clean

include ../toolchain.makefile

$(embeddedsw_archive):
	curl -JLO $(embeddedsw_url)

$(embeddedsw_sources): $(embeddedsw_archive)
	tar -xf $<
	touch $@

$(pmu_obj): $(embeddedsw_sources) $(pmu_obj_src) $(aarch64_linux_marker)
	$(aarch64_linux_gcc) -c $(pmu_obj_src) \
		-I $(embeddedsw_dir)/lib/bsp/standalone/src/common/ \
		-I $(embeddedsw_dir)/lib/sw_services/xilpm/src/zynqmp/client/common/
	$(aarch64_linux_cross)objcopy -O binary $(pmu_obj_obj) $(pmu_obj)

$(pmufw):
	curl -JLO $(pmufw_url)

$(atf_archive):
	curl -JLO $(atf_url)

$(atf_makefile): $(atf_archive)
	tar -xf $<

$(atf_bin): $(atf_makefile) $(aarch64_none_marker)
	$(MAKE) -C $(atf_dir) CROSS_COMPILE=$(aarch64_none_cross) PLAT=zynqmp RESET_TO_BL31=1 bl31

$(dts_destination): $(u_boot_unpacked) $(dts_source)
	cp $(dts_source) $(dts_destination)

$(psu_init_source): $(xsa_source)
	unzip -u -x $(xsa_source) -d $(xsa_dir)
	cd $(xsa_dir); patch -p 1 < ../$(psu_init_file).c.patch

$(psu_init_header): $(psu_init_source)

$(u_boot_board_dir): $(u_boot_unpacked)
	mkdir -p $@

$(psu_init_installed): $(psu_init_header) $(psu_init_source) $(u_boot_board_dir)
	cp $(psu_init_header) $(psu_init_source) $(u_boot_board_dir)

$(u_boot_archive):
	curl -JLO $(u_boot_url)

$(u_boot_unpacked): $(u_boot_archive)
	tar -xf $<
	touch $@

$(u_boot_patches_dir): $(u_boot_unpacked)
	ln -s ../patches $(u_boot_patches_dir)

$(u_boot_patched): $(u_boot_patches_dir)
	cd $(u_boot_dir); quilt push -a
	touch $@

$(u_boot_current_config): $(u_boot_patched) $(aarch64_linux_marker)
	CROSS_COMPILE=$(aarch64_linux_cross) ARCH=aarch64 $(MAKE) -C $(u_boot_dir) xilinx_zynqmp_virt_defconfig
	cd $(u_boot_dir); ./scripts/config --set-str DEFAULT_DEVICE_TREE "$(board_name)"
	cd $(u_boot_dir); ./scripts/config --set-str PMUFW_INIT_FILE "$(abspath $(pmufw))"
	cd $(u_boot_dir); ./scripts/config --set-str ZYNQMP_SPL_PM_CFG_OBJ_FILE "$(abspath $(pmu_obj))"
	cd $(u_boot_dir); ./scripts/config --set-val CONFIG_ZYNQ_GEM_I2C_MAC_OFFSET 0xFA
	cd $(u_boot_dir); ./scripts/config --set-val CMD_EEPROM y
	cd $(u_boot_dir); ./scripts/config --set-val CMD_EEPROM_LAYOUT n
	cd $(u_boot_dir); ./scripts/config --set-val SYS_I2C_EEPROM_BUS 1
	cd $(u_boot_dir); ./scripts/config --set-val SYS_I2C_EEPROM_ADDR_LEN 1
	cd $(u_boot_dir); ./scripts/config --set-val SYS_EEPROM_SIZE 256
	cd $(u_boot_dir); ./scripts/config --set-val SYS_EEPROM_PAGE_WRITE_BITS 8
	cd $(u_boot_dir); ./scripts/config --set-val SYS_EEPROM_PAGE_WRITE_DELAY_MS 0
	CROSS_COMPILE=$(aarch64_linux_cross) ARCH=aarch64 $(MAKE) -C $(u_boot_dir) oldconfig

$(u_boot_built): $(u_boot_patched) $(pmu_obj) $(pmufw) $(atf_bin) $(dts_destination) $(psu_init_installed) $(u_boot_current_config) $(aarch64_linux_marker)
	BL31=$(abspath $(atf_bin)) CONFIG_PMUFW_INIT_FILE=../zynqmp-pmufw-builder/pmufw.bin CROSS_COMPILE=$(aarch64_linux_cross) ARCH=aarch64 $(MAKE) -C $(u_boot_dir) -j$(num_jobs)
	touch $@

clean:
	rm -f $(pmu_obj) $(pmu_obj_obj) $(pmu_obj) $(atf_bin)
	rm -rf $(atf_dir) $(embeddedsw_dir) $(u_boot_dir) $(xsa_dir)
