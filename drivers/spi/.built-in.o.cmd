cmd_drivers/spi/built-in.o :=  toolchain/bin/arm-linux-gnueabihf-ld -EL    -r -o drivers/spi/built-in.o drivers/spi/spi.o drivers/spi/spi_bitbang.o drivers/spi/spi_gpio.o 
