cmd_ipc/built-in.o :=  /home/demo/Vidéos/wave_sd/toolchain/bin/arm-linux-gnueabihf-ld -EL    -r -o ipc/built-in.o ipc/util.o ipc/msgutil.o ipc/msg.o ipc/sem.o ipc/shm.o ipc/ipcns_notifier.o ipc/syscall.o ipc/ipc_sysctl.o 