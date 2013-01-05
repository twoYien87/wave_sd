cmd_arch/arm/boot/Image := toolchain/bin/arm-linux-gnueabihf-objcopy -O binary -R .comment -S  vmlinux arch/arm/boot/Image
