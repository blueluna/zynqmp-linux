#!/bin/sh

set -eu

ln -fs /usr/share/zoneinfo/Europe/Stockholm /etc/localtime

echo "myir-fz3" > /etc/hostname

pacman-key --init

pacman-key --populate archlinuxarm

if ! id erik 1>/dev/null 2>/dev/null; then
    echo "Creating user erik"
    useradd --create-home --shell /bin/bash -G uucp,wheel erik
    echo "erik:myir" | chpasswd
fi
echo "root:Heml1gt" | chpasswd

sed -i 's/^#en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^#sv_SE.UTF-8 UTF-8/sv_SE.UTF-8 UTF-8/' /etc/locale.gen
locale-gen

systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

systemctl enable chronyd
systemctl enable systemd-networkd
systemctl enable sshd
systemctl enable haveged
systemctl enable systemd-resolved
