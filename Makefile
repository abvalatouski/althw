.PHONY: all
all: server.s
	arm-linux-gnueabi-as server.s -o server.o
	arm-linux-gnueabi-ld server.o -o server

.PHONY: run
run: server
	qemu-arm ./server

.PHONY: clean
clean:
	rm server.o
	rm server
