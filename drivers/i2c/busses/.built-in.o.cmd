cmd_drivers/i2c/busses/built-in.o :=  toolchain/bin/arm-linux-gnueabihf-ld -EL    -r -o drivers/i2c/busses/built-in.o drivers/i2c/busses/i2c-gpio.o drivers/i2c/busses/i2c-s3c2410.o 
