IDIR=src/include
SDIR=src/c
CFLAGS+=-fPIC -DKXVER=3 -g -O2 
INCLUDES=

ifeq ($(shell uname),Linux)
QLIBDIR=l64
LDFLAGS=-shared 
else ifeq ($(shell uname),Darwin)
QLIBDIR=m64
LDFLAGS=-bundle -undefined dynamic_lookup -L/usr/local/lib -Xlinker -rpath -Xlinker /usr/local/lib
INCLUDES+=-I/usr/local/include
endif
ifeq (x$QHOME,x)
$(error QHOME not defined)
endif
jupyterq: $(QLIBDIR)/jupyterq.so
	
$(QLIBDIR)/jupyterq.so: $(SDIR)/jupyterq.c $(IDIR)/k.h
	mkdir -p $(QLIBDIR)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< -I$(IDIR)
$(IDIR)/k.h:
	curl -o $@ https://raw.githubusercontent.com/KxSystems/kdb/master/c/c/k.h
install:
	jupyter kernelspec install --user --name=qpk kernelspec
	cp jupyterq*.q $(QHOME)
	cp -r kxpy $(QHOME)
	cp ${QLIBDIR}/jupyterq.so $(QHOME)/$(QLIBDIR)

