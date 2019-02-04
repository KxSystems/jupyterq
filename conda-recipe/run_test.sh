#!/bin/bash
if [ -e ${QLIC}/kc.lic ] || [ -e ${QLIC}/k4.lic ]
then
  tests/test.sh
else
  echo No kdb+, no tests;
fi
