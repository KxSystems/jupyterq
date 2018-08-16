#!/bin/bash
if [ -e ${QLIC}/kc.lic ] 
then
  tests/test.sh
else
  echo No kdb+, no tests;
fi
