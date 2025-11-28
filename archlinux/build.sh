#!/bin/sh

set -eu

base_dir=$(readlink -e "$(dirname "${0}")")
data_dir=${base_dir}/data

sudo -p "Please enter you admin password: " true || { echo "Failed to run as administrator"; exit 1; }

rootfs_dir=${base_dir}/rootfs

mkdir -p "${rootfs_dir}"

sudo chown -R root:root "${rootfs_dir}"
sudo chmod 755 "${rootfs_dir}"

sudo mount --bind "${rootfs_dir}" "${rootfs_dir}"

sudo pacman-key --recv-keys 68B3537F39A313B3E574D06777193F152BDBE6A6
sudo pacman-key --lsign-key 68B3537F39A313B3E574D06777193F152BDBE6A6

sudo pacstrap -M -K -C "${data_dir}/pacman.aarch64.conf" "${rootfs_dir}" archlinuxarm-keyring base base-devel chrony openssh haveged mg mtd-utils sudo uboot-tools

sudo cp "$(which qemu-aarch64-static)" "${rootfs_dir}/usr/bin"
sudo cp "${data_dir}/system_setup.sh" "${rootfs_dir}/root/system_setup.sh"
sudo cp "${rootfs_dir}/usr/lib/systemd/network/89-ethernet.network.example" "${rootfs_dir}/etc/systemd/network/89-ethernet.network"

sudo arch-chroot "${rootfs_dir}" /bin/bash /root/system_setup.sh

# Enable sudo for wheel group
sudo sed -i 's/^#\s*\(%wheel\s*ALL=(ALL:ALL)\s*ALL\)/\1/' "${rootfs_dir}/etc/sudoers"

sudo cp "${data_dir}/locale.conf" "${rootfs_dir}/etc/locale.conf"
sudo cp "${data_dir}/fw_env.config" "${rootfs_dir}/etc/fw_env.config"

command=gpg-agent
# Kill any gpg-agent processes using the rootfs to avoid "device busy" errors
for pid in $(pidof ${command}); do
    cat "/proc/${pid}/cmdline" | tr \\0 \ | grep -q "${rootfs_dir}" && { sudo kill "${pid}"; }
done

sudo tar -C "${rootfs_dir}" --acl --xattrs --numeric-owner --exclude-from "${data_dir}/exclude.txt" -JpScf "${base_dir}/archlinux.tar.xz" .

sudo umount -R "${rootfs_dir}"

sudo -k

echo "Arch Linux ARM root filesystem created at: ${base_dir}/archlinux.tar.xz"
