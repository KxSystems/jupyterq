#!/usr/bin/env q
@[hdel;`:makefile;0];
h:neg hopen`:makefile
QHOME:hsym $[null u:`$getenv`QHOME;[-2"QHOME must be defined";exit 1];u]
QLIBDIR:` sv QHOME,.z.o
if[0~@[system;"l p.q";0];-2"embedPy must be installed with p.q in QHOME for jupyterq";exit 2];
h"QHOME=",1_string QHOME;
h"QLIBDIR=",1_string QLIBDIR;
h each read0`:makefile.in;
exit 0
