cmd_sound/core/built-in.o :=  toolchain/bin/arm-linux-gnueabihf-ld -EL    -r -o sound/core/built-in.o sound/core/snd.o sound/core/snd-timer.o sound/core/snd-pcm.o sound/core/snd-page-alloc.o 