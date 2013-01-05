cmd_kernel/events/built-in.o :=  toolchain/bin/arm-linux-gnueabihf-ld -EL    -r -o kernel/events/built-in.o kernel/events/core.o kernel/events/hw_breakpoint.o 
