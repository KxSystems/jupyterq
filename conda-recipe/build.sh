#!/bin/bash
export QHOME=$PREFIX/q
if [ $(uname) == Linux ];
then
	QLIBDIR=l64
else
	QLIBDIR=m64
fi
make -f build/makefile jupyterq
mkdir -p $QHOME/$QLIBDIR
jupyter kernelspec install --user --name=qpk kernelspec
cp jupyterq*.q $QHOME
cp -r kxpy $QHOME
cp $QLIBDIR/jupyterq.so $QHOME/$QLIBDIR
