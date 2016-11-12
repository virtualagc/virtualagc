.PHONY: all
.PHONY: default
all default:	yaUplinkBlock1

yaUplinkBlock1: yaUplinkBlock1.c ../yaAGCb1/SocketAPI.c ../yaAGCb1/agc_utilities.c
	gcc -o $@ $^ -lncurses

.PHONY: clean
clean:
	-rm yaUplinkBlock1
