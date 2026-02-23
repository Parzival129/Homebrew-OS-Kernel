#!/bin/sh
set -e
. ./build.sh

mkdir -p isodir
mkdir -p isodir/boot
mkdir -p isodir/boot/grub

cp sysroot/boot/SaruKernel.kernel isodir/boot/SaruKernel.kernel
cat > isodir/boot/grub/grub.cfg << EOF
menuentry "SaruKernel" {
	multiboot /boot/SaruKernel.kernel
}
EOF
grub-mkrescue -o SaruKernel.iso isodir
