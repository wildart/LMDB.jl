CC	= gcc
W	= -W -Wall -Wno-unused-parameter -Wbad-function-cast
THREADS = -pthread
OPT = -O2 -g
CFLAGS	= $(THREADS) $(OPT) $(W) $(XCFLAGS)
SRCDIR = ../../src/lmdbwrapper
PREFIX = ../../usr

all: liblmdbwrapper.so

liblmdbwrapper.so:
	$(CC) -pthread -fPIC -shared $(CFLAGS) $(SRCDIR)/wrapper.c -o liblmdbwrapper.so -I$(LMDBINC) -L$(PREFIX)/lib -llmdb

clean:
	rm *.so

install:
	mkdir -p $(PREFIX)/lib
	cp liblmdbwrapper.so $(PREFIX)/lib