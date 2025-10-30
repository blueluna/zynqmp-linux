# SPDX-License-Identifier: MIT
# Common rules
#
# Author: Erik Banvik <erik.public@gmail.com>

$(download_dir):
	$(Q)mkdir -p $@

$(output_dir):
	$(Q)mkdir -p $@

$(rootfs_dir):
	$(Q)mkdir -p $@

$(aarch64_none_archive_path): $(download_dir)
	$(Q)curl -JLO $(aarch64_none_url) --output-dir $(download_dir)

$(aarch64_none_marker): $(aarch64_none_archive_path)
	$(Q)tar -x -C $(base_dir) -f $<
	$(Q)touch $@

$(aarch64_linux_archive_path): $(download_dir)
	$(Q)curl -JLO $(aarch64_linux_url) --output-dir $(download_dir)

$(aarch64_linux_marker): $(aarch64_linux_archive_path)
	$(Q)tar -x -C $(base_dir) -f $<
	$(Q)touch $@
