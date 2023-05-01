# SPDX-License-Identifier: MIT
# Debian filesystem
#
# Author: Erik Banvik <erik.public@gmail.com>

include ../constants.makefile

run=chroot $(rootfs_dir)

all: $(rootfs_done)

.PHONY: clean

include ../common.makefile

$(rootfs_first_stage): $(rootfs_dir)
	debootstrap --foreign --arch=arm64 --components=main,contrib,non-free,non-free-firmware testing $(rootfs_dir) http://ftp.se.debian.org/debian/
#	fakechroot fakeroot debootstrap --foreign --variant=fakechroot --arch=arm64 --components=main,contrib,non-free,non-free-firmware testing $(rootfs_dir) http://ftp.se.debian.org/debian/
	touch $@

$(rootfs_second_stage): $(rootfs_first_stage)
	cp $(shell which qemu-aarch64-static) $(rootfs_dir)/usr/bin/
	$(run) ./debootstrap/debootstrap --second-stage
	touch $@

$(rootfs_done): $(rootfs_second_stage)
	LC_ALL=C $(run) dpkg --configure -a
	LC_ALL=C $(run) /usr/bin/ln -fs /usr/share/zoneinfo/Europe/Stockholm /etc/localtime && /usr/sbin/dpkg-reconfigure --frontend noninteractive tzdata
	LC_ALL=C $(run) apt-get install -y locales
	LC_ALL=C $(run) /bin/sh -c "echo \"locales locales/locales_to_be_generated multiselect en_GB.UTF-8 sv_SE.UTF-8 UTF-8\" | debconf-set-selections"
	LC_ALL=C $(run) /bin/sh -c "echo \"locales locales/default_environment_locale select en_GB.UTF-8\" | debconf-set-selections"
	rm $(rootfs_dir)/etc/locale.gen
	LC_ALL=C $(run) dpkg-reconfigure --frontend noninteractive locales
	mount -t proc /proc $(rootfs_dir)/proc
	echo "te0802" > $(rootfs_dir)/etc/hostname
	$(run) apt-get install -y htop openssh-server policykit-1 sudo systemd-timesyncd
	cp $(rootfs_dir)/usr/lib/systemd/network/80-ethernet.network.example $(rootfs_dir)/etc/systemd/network/80-ethernet.network
	$(run) useradd --create-home --shell /bin/bash -G adm,dialout,sudo erik
	$(run) /bin/sh -c "echo \"root:s3cr37\nerik:te0802\" | chpasswd"
	$(run) systemctl enable ssh
	$(run) systemctl enable systemd-timesyncd
	$(run) systemctl enable systemd-networkd
	$(run) apt-get install -y systemd-resolved
	$(run) systemctl enable systemd-resolved
	rm -rf $(rootfs_dir)/dev/*
	touch $@

clean:
	rm -rf $(rootfs_dir)
