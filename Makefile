# All Rights Reversed - No Rights Reserved
#
# Written by ILEV Trebla at Sweetmorn,
# the 64th day of The Aftermath in the YOLD 3180

eXe = daemonize

OBJS = $(eXe).o

#DEBUG = yupp
ifdef DEBUG
DBGFLAGS = -g -O0
else
DBGFLAGS = -O2
endif

CFLAGS = -W -Wall $(DBGFLAGS)

PREFIX = /usr/local/bin

all: $(eXe)

$(eXe): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS)

install: $(eXe)
	cp -f $(eXe) vpnguardian.sh $(PREFIX)
	chmod 755 $(PREFIX)/$(eXe)
	chmod 755 $(PREFIX)/vpnguardian.sh
	if test -d /etc/local.d/; then \
	  cp -f 03-vpnguardian.start /etc/local.d/; \
	  chmod 755 /etc/local.d/03-vpnguardian.start; \
	fi

.PHONY: clean uninstall

uninstall:
	rm -f $(PREFIX)/$(eXe)
	rm -f $(PREFIX)/vpnguardian.sh
	rm -f etc/local.d/03-vpnguardian.start

clean:
	rm -f $(eXe) $(OBJS) *~
