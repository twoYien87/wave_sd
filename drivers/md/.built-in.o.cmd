cmd_drivers/md/built-in.o :=  toolchain/bin/arm-linux-gnueabihf-ld -EL    -r -o drivers/md/built-in.o drivers/md/dm-mod.o drivers/md/dm-crypt.o drivers/md/dm-snapshot.o 
