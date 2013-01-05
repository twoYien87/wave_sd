cmd_fs/ramfs/ramfs.o := toolchain/bin/arm-linux-gnueabihf-ld -EL    -r -o fs/ramfs/ramfs.o fs/ramfs/inode.o fs/ramfs/file-mmu.o 
