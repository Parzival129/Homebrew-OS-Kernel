#!/bin/sh
set -e
. ./build.sh

mkdir -p isodir
mkdir -p isodir/boot
mkdir -p isodir/boot/grub

cp sysroot/boot/nue_kernel.kernel isodir/boot/nue_kernel.kernel
cat > isodir/boot/grub/grub.cfg << EOF
menuentry "nue_kernel" {
	multiboot /boot/nue_kernel.kernel
}
EOF
grub-mkrescue -o nue_kernel.iso isodir
