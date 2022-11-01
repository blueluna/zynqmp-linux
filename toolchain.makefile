this_dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

download_dir=$(this_dir)/downloads

aarch64_none_triplet=aarch64-none-elf
aarch64_none_version=11.2-2022.02
aarch64_none_dir=gcc-arm-$(aarch64_none_version)-x86_64-$(aarch64_none_triplet)
aarch64_none_archive=$(aarch64_none_dir).tar.xz
aarch64_none_archive_path=$(download_dir)/$(aarch64_none_archive)
aarch64_none_url=https://developer.arm.com/-/media/Files/downloads/gnu/$(aarch64_none_version)/binrel/$(aarch64_none_archive)
aarch64_none_bin=$(this_dir)/$(aarch64_none_dir)/bin
aarch64_none_cross=$(aarch64_none_bin)/$(aarch64_none_triplet)-
aarch64_none_gcc=$(aarch64_none_cross)gcc
aarch64_none_marker=$(this_dir)/$(aarch64_none_dir)/.unpacked

aarch64_linux_triplet=aarch64-none-linux-gnu
aarch64_linux_version=11.2-2022.02
aarch64_linux_dir=gcc-arm-$(aarch64_linux_version)-x86_64-$(aarch64_linux_triplet)
aarch64_linux_archive=$(aarch64_linux_dir).tar.xz
aarch64_linux_archive_path=$(download_dir)/$(aarch64_linux_archive)
aarch64_linux_url=https://developer.arm.com/-/media/Files/downloads/gnu/$(aarch64_linux_version)/binrel/$(aarch64_linux_archive)
aarch64_linux_bin=$(this_dir)/$(aarch64_linux_dir)/bin
aarch64_linux_cross=$(aarch64_linux_bin)/$(aarch64_linux_triplet)-
aarch64_linux_gcc=$(aarch64_linux_cross)gcc
aarch64_linux_marker=$(this_dir)/$(aarch64_linux_dir)/.unpacked

$(download_dir):
	mkdir -p $@

$(aarch64_none_archive_path): $(download_dir)
	curl -JLO $(aarch64_none_url) --output-dir $(download_dir)

$(aarch64_none_marker): $(aarch64_none_archive_path)
	tar -x -C $(this_dir) -f $<
	touch $@

$(aarch64_linux_archive_path): $(download_dir)
	curl -JLO $(aarch64_linux_url) --output-dir $(download_dir)

$(aarch64_linux_marker): $(aarch64_linux_archive_path)
	tar -x -C $(this_dir) -f $<
	touch $@
