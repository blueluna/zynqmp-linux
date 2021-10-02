# Hi

embeddedsw_dir=embeddedsw
embeddedsw_sources=$(embeddedsw_dir)/.sources

pmu_obj_obj=pm_cfg_obj.o
pmu_obj_src=$(pmu_obj_obj:%.o=%.c)
pmu_obj=pmu_obj.bin

u_boot_dir=u-boot
u_boot_archive=u-boot-2021.07.tar.bz2
u_boot_url=https://ftp.denx.de/pub/u-boot/$(u_boot_archive)
u_boot_unpacked=$(u_boot_dir)/Makefile
u_boot_patches_dir=$(u_boot_dir)/patches
u_boot_patched=$(u_boot_dir)/.patched
u_boot_built=$(u_boot_dir)/.built

make_jobs=$(shell nproc)

all: $(u_boot_built)

.PHONY: clean

$(embeddedsw_sources):
	git clone https://github.com/Xilinx/embeddedsw.git
	cd $(embeddedsw_dir); git checkout xilinx_v2021.1
	touch $@

$(pmu_obj): $(embeddedsw_sources)
	gcc -c $(pmu_obj_src) \
		-I $(embeddedsw_dir)/lib/bsp/standalone/src/common/ \
		-I $(embeddedsw_dir)/lib/sw_services/xilpm/src/zynqmp/client/common/
	objcopy -O binary $(pmu_obj_obj) $(pmu_obj)

clean:
	rm -f $(pmu_obj) $(pmu_obj_obj)

$(u_boot_archive):
	curl -J -L -O $(u_boot_url)
	touch $@

$(u_boot_dir):
	mkdir -p $@

$(u_boot_unpacked): $(u_boot_archive) $(u_boot_dir)
	tar -x -C $(u_boot_dir) --strip-components=1 -f $<

$(u_boot_patches_dir): $(u_boot_unpacked)
	ln -s ../patches $(u_boot_patches_dir)

$(u_boot_patched): $(u_boot_patches_dir)
	cd $(u_boot_dir); quilt push -a
	touch $@

$(u_boot_built): $(u_boot_patched)
	CROSS_COMPILE=aarch64-linux-gnu- ARCH=aarch64 $(MAKE) -C $(u_boot_dir) trenz-electronic-te0802-02_defconfig
	BL31=../bl31.bin CONFIG_PMUFW_INIT_FILE=../zynqmp-pmufw-builder/pmufw.bin CROSS_COMPILE=aarch64-linux-gnu- ARCH=aarch64 $(MAKE) -C $(u_boot_dir) -j $(make_jobs)
	touch $@
