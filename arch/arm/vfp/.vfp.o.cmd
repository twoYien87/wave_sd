cmd_arch/arm/vfp/vfp.o := toolchain/bin/arm-linux-gnueabihf-ld -EL  --no-warn-mismatch   -r -o arch/arm/vfp/vfp.o arch/arm/vfp/vfpmodule.o arch/arm/vfp/entry.o arch/arm/vfp/vfphw.o arch/arm/vfp/vfpsingle.o arch/arm/vfp/vfpdouble.o 