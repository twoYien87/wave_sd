cmd_firmware/samsung_mfc_fw.bin.gen.o := /home/demo/Vidéos/wave_sd/toolchain/bin/arm-linux-gnueabihf-gcc -Wp,-MD,firmware/.samsung_mfc_fw.bin.gen.o.d  -nostdinc -isystem /home/demo/Vidéos/wave_sd/toolchain/bin/../lib/gcc/arm-linux-gnueabihf/4.7.3/include -I/home/demo/Vidéos/wave_sd/arch/arm/include -Iarch/arm/include/generated -Iinclude  -include include/generated/autoconf.h -D__KERNEL__ -mlittle-endian -Iarch/arm/mach-s5pv210/include -Iarch/arm/plat-s5p/include -Iarch/arm/plat-samsung/include -D__ASSEMBLY__ -mabi=aapcs-linux -mno-thumb-interwork -funwind-tables  -D__LINUX_ARM_ARCH__=7 -march=armv7-a  -include asm/unified.h -msoft-float        -c -o firmware/samsung_mfc_fw.bin.gen.o firmware/samsung_mfc_fw.bin.gen.S

source_firmware/samsung_mfc_fw.bin.gen.o := firmware/samsung_mfc_fw.bin.gen.S

deps_firmware/samsung_mfc_fw.bin.gen.o := \
  /home/demo/Vidéos/wave_sd/arch/arm/include/asm/unified.h \
    $(wildcard include/config/arm/asm/unified.h) \
    $(wildcard include/config/thumb2/kernel.h) \

firmware/samsung_mfc_fw.bin.gen.o: $(deps_firmware/samsung_mfc_fw.bin.gen.o)

$(deps_firmware/samsung_mfc_fw.bin.gen.o):
