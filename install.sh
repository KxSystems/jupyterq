#!/bin/bash
Q=$(which q)
if [ "x$Q" == "x" ]
then
	echo q not found, must be on PATH >&2
	exit 1
fi
ZO=$(echo "-1 string .z.o;"|q -q)
if [ "x$QHOME" == "x" ]
then
 	echo QHOME must be set >&2
	exit 1
elif [ ! -d "$QHOME" ]
then
	echo QHOME:$QHOME does not exist >&2
	exit 1
elif [ ! -d "${QHOME}/${ZO}" ]
then
	mkdir -p ${QHOME}/${ZO}
fi
src=$(dirname $0)
set -x
jupyter kernelspec install --user --name=qpk ${src}/kernelspec
cp ${src}/jupyterq*.q?(_) $QHOME
cp -r ${src}/kxpy $QHOME
cp ${src}/${ZO}/jupyterq.so $QHOME/$ZO




