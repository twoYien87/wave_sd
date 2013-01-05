cmd_drivers/mmc/built-in.o :=  toolchain/bin/arm-linux-gnueabihf-ld -EL    -r -o drivers/mmc/built-in.o drivers/mmc/core/built-in.o drivers/mmc/card/built-in.o drivers/mmc/host/built-in.o 
