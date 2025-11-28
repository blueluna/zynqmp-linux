#!/bin/sh

set -eu

base_dir=$(readlink -e $(dirname ${0}))
image_path=${base_dir}/archlinux.img
data_dir=${base_dir}/data
rootfs_dir=${base_dir}/rootfs

sudo -p "Please enter you admin password: " true || { echo "Failed to run as administrator"; exit 1; }

fallocate -l 4G ${image_path}

lo_device=$(sudo losetup --show -fP ${image_path})

sudo parted --script ${lo_device} \
    mklabel gpt \
    mkpart primary fat32 0% 250MiB \
    mkpart primary ext4 250MiB 100% \
    set 1 boot on

lo_boot_partition=${lo_device}p1
lo_root_partition=${lo_device}p2

sudo mkfs.vfat -n BOOT ${lo_boot_partition}
sudo mkfs.ext4 -L ROOT ${lo_root_partition}

mkdir -p ${rootfs_dir}

sudo mount ${lo_root_partition} ${rootfs_dir}

sudo pacman-key --recv-keys 68B3537F39A313B3E574D06777193F152BDBE6A6
sudo pacman-key --lsign-key 68B3537F39A313B3E574D06777193F152BDBE6A6

sudo pacstrap -M -K -C ${data_dir}/pacman.aarch64.conf ${rootfs_dir} archlinuxarm-keyring base base-devel chrony openssh haveged mg mtd-utils sudo

sudo cp $(which qemu-aarch64-static) ${rootfs_dir}/usr/bin
sudo cp ${data_dir}/system_setup.sh ${rootfs_dir}/root/system_setup.sh
sudo cp ${rootfs_dir}/usr/lib/systemd/network/89-ethernet.network.example ${rootfs_dir}/etc/systemd/network/89-ethernet.network

sudo arch-chroot ${rootfs_dir} /bin/bash /root/system_setup.sh

command=gpg-agent
# Kill any gpg-agent processes using the rootfs to avoid "device busy" errors
for pid in $(pidof ${command}); do
    cat /proc/${pid}/cmdline | tr \\0 \ | grep -q ${rootfs_dir} && { sudo kill ${pid}; }
done

sudo umount -R ${rootfs_dir}

sudo losetup -d ${lo_device}

sudo -k
