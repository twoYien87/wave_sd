cmd_arch/arm/boot/zImage := toolchain/bin/arm-linux-gnueabihf-objcopy -O binary -R .comment -S  arch/arm/boot/compressed/vmlinux arch/arm/boot/zImage
