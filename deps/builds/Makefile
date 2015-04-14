CC	= gcc
W	= -W -Wall -Wno-unused-parameter -Wbad-function-cast
THREADS = -pthread
OPT = -O2 -g
CFLAGS	= $(THREADS) $(OPT) $(W)
SRCDIR = ../src
PREFIX = ../usr
#LMDBLIB = ../usr/lib/liblmdbjl.so

all: $(LMDBLIB)

$(LMDBLIB):
	mkdir -p $(PREFIX)/lib
	$(CC) -fPIC -shared $(CFLAGS) $(SRCDIR)/wrapper.c $(LMDBSRC)/mdb.c $(LMDBSRC)/midl.c -o $(LMDBLIB) -I$(LMDBSRC)

clean:
	rm $(LMDBLIB)