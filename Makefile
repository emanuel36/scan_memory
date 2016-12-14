CROSS_COMPILE ?= arm-linux-gnueabihf-

all: AP1.s
	$(CROSS_COMPILE)as AP1.s -o AP1.o
	$(CROSS_COMPILE)ld -o AP1 -T memmap AP1.o
	$(CROSS_COMPILE)objcopy AP1 AP1.bin -O binary
	mv AP1.bin /tftpboot/teste.bin
	rm *.o
	rm AP1

clean:
	rm *.o *.bin *.lst
