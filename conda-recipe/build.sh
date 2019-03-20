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
JK=$PREFIX/share/jupyter/kernels/qpk
JL=jupyterq_licensemgr/jupyterq_licensemgr
mkdir -p $JK $PREFIX/etc/jupyter/nbconfig/notebook.d $PREFIX/etc/jupyter/jupyter_notebook_config.d $PREFIX/share/jupyter/nbextensions/jupyterq_licensemgr
cp kernelspec/* $JK
(cd jupyterq_licensemgr && python setup.py install)
cp $JL/index.js $PREFIX/share/jupyter/nbextensions/jupyterq_licensemgr
cp $JL/jupyterq_licensemgr.json $PREFIX/etc/jupyter/nbconfig/notebook.d
cp $JL/jupyterq_licensemgr_config.json $PREFIX/etc/jupyter/jupyter_notebook_config.d
cp jupyterq*.q $QHOME
cp -r kxpy $QHOME
cp $QLIBDIR/jupyterq.so $QHOME/$QLIBDIR
