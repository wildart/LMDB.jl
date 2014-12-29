CC	= gcc
W	= -W -Wall -Wno-unused-parameter -Wbad-function-cast
THREADS = -pthread
OPT = -O2 -g
CFLAGS	= $(THREADS) $(OPT) $(W)
SRCDIR = ../src
PREFIX = ../usr
LMDBLIB = liblmdbjl.so

all: $(LMDBLIB)

$(LMDBLIB):
	$(CC) -fPIC -shared $(CFLAGS) $(SRCDIR)/wrapper.c $(LMDBSRC)/mdb.c $(LMDBSRC)/midl.c -o $(LMDBLIB) -I$(LMDBSRC)

clean:
	rm *.so

install:
	mkdir -p $(PREFIX)/lib
	cp $(LMDBLIB) $(PREFIX)/lib