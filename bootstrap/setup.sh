#!/bin/sh
fdisk /dev/sda << EOF
n
p
1


a
1
w
EOF
mke2fs /dev/sda1
mount /dev/sda1 /mnt/disk
mount /dev/hdc /mnt/cdrom
tar -xzf /mnt/cdrom/rootfs.tgz -C /mnt/disk
chown -R 0:0 /mnt/disk
mkdir -p /mnt/disk/boot/extlinux
cat > /mnt/disk/boot/extlinux/extlinux.conf << EOF
default linux
label linux
kernel /boot/bzImage
append root=/dev/sda1 vga=835 rw
EOF
extlinux -i /mnt/disk/boot/extlinux
umount /mnt/cdrom
umount /mnt/disk
dd if=/share/syslinux/mbr.bin of=/dev/sda
