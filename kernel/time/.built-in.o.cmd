cmd_kernel/time/built-in.o :=  /home/demo/Vidéos/wave_sd/toolchain/bin/arm-linux-gnueabihf-ld -EL    -r -o kernel/time/built-in.o kernel/time/timekeeping.o kernel/time/ntp.o kernel/time/clocksource.o kernel/time/jiffies.o kernel/time/timer_list.o kernel/time/timecompare.o kernel/time/timeconv.o kernel/time/posix-clock.o kernel/time/clockevents.o kernel/time/tick-common.o kernel/time/tick-oneshot.o kernel/time/tick-sched.o 