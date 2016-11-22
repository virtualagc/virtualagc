.PHONY: all
.PHONY: default
all default:	yaUplinkBlock1

ifdef SOLARIS
EXTRAS=-DSOLARIS=yes
LIBS=-lxnet
endif
ifdef WIN32
EXTRAS=-I/usr/include -Wno-deprecated-declarations
LIBS=-L/usr/lib -lwsock32
endif

yaUplinkBlock1: yaUplinkBlock1.c ../yaAGCb1/SocketAPI.c ../yaAGCb1/agc_utilities.c
	${cc} $(EXTRAS) -o $@ $^ $(LIBS) -lncurses

.PHONY: clean
clean:
	-rm yaUplinkBlock1
