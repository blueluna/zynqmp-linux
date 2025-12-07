# SPDX-License-Identifier: MIT
# Bootloader for ZynqMP
#
# Author: Erik Banvik <erik.public@gmail.com>

include ../constants.makefile

board_dir_u_boot=$(board_dir)/u-boot

embeddedsw_dir=embeddedsw-xilinx_$(xilinx_version)
embeddedsw_url=https://github.com/Xilinx/embeddedsw/archive/refs/tags/xilinx_$(xilinx_version).tar.gz
embeddedsw_archive=$(embeddedsw_dir).tar.gz
embeddedsw_sources=$(embeddedsw_dir)/.sources

pmufw=pmufw-v2025.1.bin
pmufw_url=https://github.com/lucaceresoli/zynqmp-pmufw-binaries/raw/master/bin/$(pmufw)

pmu_obj_obj=pm_cfg_obj.o
pmu_obj_src=$(pmu_obj_obj:%.o=%.c)
pmu_obj=pmu_obj.bin

atf_url=https://github.com/Xilinx/arm-trusted-firmware/archive/refs/tags/$(xilinx_tag).tar.gz
atf_dir=$(abspath arm-trusted-firmware-xilinx-$(xilinx_version))
atf_archive=$(atf_dir).tar.gz
atf_makefile=$(atf_dir)/Makefile
atf_bin=$(atf_dir)/build/zynqmp/release/bl31.bin

optee_os_version=4.8.0
optee_os_name=optee_os-$(optee_os_version)
optee_os_dir=$(abspath $(optee_os_name))
optee_os_archive=$(optee_os_dir).tar.gz
optee_os_url=https://github.com/OP-TEE/optee_os/archive/refs/tags/$(optee_os_version).tar.gz
optee_os_output_dir=$(optee_os_dir)/out/arm/core/
optee_os_elf=$(optee_os_output_dir)tee.elf
optee_os_raw_bin=$(optee_os_output_dir)tee_raw.bin

u_boot_version=2025.10
u_boot_dir=u-boot-$(u_boot_version)
u_boot_archive=$(u_boot_dir).tar.bz2
u_boot_url=https://ftp.denx.de/pub/u-boot/$(u_boot_archive)
u_boot_unpacked=$(u_boot_dir)/Makefile
u_boot_patches_dir=$(u_boot_dir)/patches
u_boot_patches_linked=$(u_boot_dir)/.patches_linked
u_boot_patched=$(u_boot_dir)/.patched
u_boot_built=$(u_boot_dir)/.built
u_boot_defconfig_src=$(board_dir_u_boot)/$(u_boot_version)/$(kernel_configuration_name)
u_boot_defconfig_dst=$(u_boot_dir)/configs/$(kernel_configuration_name)

dts_dir=$(u_boot_dir)/arch/arm/dts
dts_destination=$(dts_dir)/$(device_tree_source)

u_boot_board_dir=$(u_boot_dir)/board/xilinx/zynqmp/$(board_name)

psu_init_file=psu_init_gpl
psu_init_source=$(board_dir_u_boot)/$(psu_init_file).c
psu_init_installed=$(u_boot_board_dir)/$(psu_init_file).c

u_boot_current_config=$(u_boot_dir)/.config

u_boot_spl_image=boot.bin
u_boot_spl_image_output=$(output_dir)/$(u_boot_spl_image)

u_boot_image=u-boot.itb
u_boot_image_output=$(output_dir)/$(u_boot_image)

ifeq ($(board),$(TE0802_02_NAME))
# 1 GB
	CFG_DDR_SIZE=0x040000000
else ifeq ($(board),$(MYIR_FZ3_NAME))
# 4 GB
	CFG_DDR_SIZE=0x100000000
endif

all: $(u_boot_spl_image_output) $(u_boot_image_output)

.PHONY: clean

include ../common.makefile

$(embeddedsw_archive):
	$(Q)curl -JLO $(embeddedsw_url)

$(embeddedsw_sources): $(embeddedsw_archive)
	$(Q)tar -xf $<
	$(Q)touch $@

$(pmu_obj): $(embeddedsw_sources) $(board_dir_u_boot)/$(pmu_obj_src) $(aarch64_linux_marker)
	$(Q)$(aarch64_linux_gcc) -c $(board_dir_u_boot)/$(pmu_obj_src) \
		-I $(embeddedsw_dir)/lib/bsp/standalone/src/common/ \
		-I $(embeddedsw_dir)/lib/sw_services/xilpm/src/zynqmp/client/common/ \
		-I .
	$(Q)$(aarch64_linux_cross)objcopy -O binary $(pmu_obj_obj) $(pmu_obj)

$(pmufw):
#	curl -JLO $(pmufw_url)

$(atf_archive):
	$(Q)curl -JLO $(atf_url)

$(atf_makefile): $(atf_archive)
	$(Q)tar -xf $<

$(atf_bin): $(atf_makefile) $(aarch64_none_marker)
#	$(Q)$(MAKE) -C $(atf_dir) CROSS_COMPILE=$(aarch64_none_cross) PLAT=zynqmp RESET_TO_BL31=1 NEED_BL32=yes SPD=opteed LOG_LEVEL=LOG_LEVEL_INFO bl31
	$(Q)$(MAKE) -C $(atf_dir) CROSS_COMPILE=$(aarch64_none_cross) PLAT=zynqmp RESET_TO_BL31=1 bl31

$(optee_os_archive):
	$(Q)curl -JLO $(optee_os_url)

$(optee_os_dir): $(optee_os_archive)
	$(Q)tar -xf $<

$(optee_os_elf): $(optee_os_dir)
	$(Q)make -C $(optee_os_dir) -j$(num_jobs) \
    	O=out/arm \
    	CFG_USER_TA_TARGETS=ta_arm64 \
    	CFG_ARM64_core=y \
    	PLATFORM=zynqmp-zcu102 \
    	CFG_DDR_SIZE=$(CFG_DDR_SIZE) \
    	CROSS_COMPILE=$(aarch64_linux_cross) \
    	CROSS_COMPILE_core=$(aarch64_linux_cross) \
    	CROSS_COMPILE_ta_arm64=$(aarch64_linux_cross) \
    	CFG_TEE_CORE_LOG_LEVEL=3 \
    	DEBUG=0 \
    	CFG_IN_TREE_EARLY_TAS=trusted_keys/f04a0fe7-1f5d-4b9b-abf7-619b85b4ce8c

$(optee_os_raw_bin): $(optee_os_elf)
	$(optee_os_dir)/scripts/gen_tee_bin.py --input $< --out_tee_raw_bin $@

$(dts_destination): $(u_boot_unpacked) $(device_tree_source_path)
	$(Q)cp $(device_tree_source_path) $(dts_destination)

$(u_boot_board_dir): $(u_boot_unpacked)
	$(Q)mkdir -p $@

$(psu_init_installed): $(psu_init_source) $(u_boot_board_dir)
	$(Q)cp $(psu_init_source) $(u_boot_board_dir)

$(u_boot_archive):
	$(Q)curl -JLO $(u_boot_url)

$(u_boot_unpacked): $(u_boot_archive)
	$(Q)tar -xf $<
	$(Q)touch $@

$(u_boot_patches_linked): $(u_boot_unpacked)
	$(Q)ln -s $(board_dir_u_boot)/$(u_boot_version)/patches $(u_boot_patches_dir)
	$(Q)touch $@

$(u_boot_patched): $(u_boot_patches_linked)
	$(Q)cd $(u_boot_dir); quilt push -q -a
	$(Q)touch $@

$(u_boot_defconfig_dst): $(u_boot_defconfig_src)
	$(Q)cp $(u_boot_defconfig_src) $(u_boot_defconfig_dst)

$(u_boot_current_config): $(u_boot_patched) $(aarch64_linux_marker) $(u_boot_defconfig_dst)
	$(Q)CROSS_COMPILE=$(aarch64_linux_cross) ARCH=aarch64 $(MAKE) -C $(u_boot_dir) $(kernel_configuration_name)
	$(Q)cd $(u_boot_dir); ./scripts/config --set-str PMUFW_INIT_FILE "$(abspath $(pmufw))"
	$(Q)cd $(u_boot_dir); ./scripts/config --set-str ZYNQMP_SPL_PM_CFG_OBJ_FILE "$(abspath $(pmu_obj))"
	$(Q)CROSS_COMPILE=$(aarch64_linux_cross) ARCH=aarch64 $(MAKE) -C $(u_boot_dir) oldconfig

$(u_boot_built): $(u_boot_patched) $(pmu_obj) $(pmufw) $(atf_bin) $(dts_destination) $(psu_init_installed) $(u_boot_current_config) $(aarch64_linux_marker)
#	$(Q)BL31=$(atf_bin) TEE=$(optee_os_raw_bin) CROSS_COMPILE=$(aarch64_linux_cross) ARCH=aarch64 $(MAKE) -C $(u_boot_dir) -j$(num_jobs)
	$(Q)BL31=$(atf_bin) CROSS_COMPILE=$(aarch64_linux_cross) ARCH=aarch64 $(MAKE) -C $(u_boot_dir) -j$(num_jobs)
	$(Q)touch $@

$(u_boot_spl_image_output): $(u_boot_built) $(output_dir)
	$(Q)cp $(u_boot_dir)/spl/$(u_boot_spl_image) $(u_boot_spl_image_output)

$(u_boot_image_output): $(u_boot_built) $(output_dir)
	$(Q)cp $(u_boot_dir)/$(u_boot_image) $(u_boot_image_output)

config: 
	$(Q)CROSS_COMPILE=$(aarch64_linux_cross) ARCH=aarch64 $(MAKE) -C $(u_boot_dir) menuconfig

saveconfig:
	$(Q)CROSS_COMPILE=$(aarch64_linux_cross) ARCH=aarch64 $(MAKE) -C $(u_boot_dir) savedefconfig
	cp $(u_boot_dir)/defconfig $(u_boot_defconfig_src)

clean:
	$(Q)rm -f $(pmu_obj) $(pmu_obj_obj) $(pmu_obj) $(atf_bin)
	$(Q)rm -rf $(atf_dir) $(embeddedsw_dir) $(u_boot_dir) $(optee_os_dir)
