.PHONY: all
.PHONY: default
all default:	yaUplinkBlock1

ifdef SOLARIS
EXTRAS=-DSOLARIS=yes
LIBS=-lxnet
endif

yaUplinkBlock1: yaUplinkBlock1.c ../yaAGCb1/SocketAPI.c ../yaAGCb1/agc_utilities.c
	gcc $(EXTRAS) -o $@ $^ -lncurses $(LIBS)

.PHONY: clean
clean:
	-rm yaUplinkBlock1
