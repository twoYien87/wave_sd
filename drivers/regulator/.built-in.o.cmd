cmd_drivers/regulator/built-in.o :=  toolchain/bin/arm-linux-gnueabihf-ld -EL    -r -o drivers/regulator/built-in.o drivers/regulator/core.o drivers/regulator/dummy.o drivers/regulator/max8998.o 
