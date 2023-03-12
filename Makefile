CC = /usr/bin/gcc
OPENSSL_INCLUDE = "/opt/homebrew/opt/openssl@3/include"
OPENSSL_LIB = "/opt/homebrew/opt/openssl@3/lib"
CFLAGS = -Wall -Werror -g
LDFLAGS = -lcrypto -lssl -I$(OPENSSL_INCLUDE) -L$(OPENSSL_LIB)

all: build

build: client.h server.h
	$(CC) $(CFLAGS) -o openssl main.c client.c server.c $(LDFLAGS)

clean:
	rm -f *.o core openssl
