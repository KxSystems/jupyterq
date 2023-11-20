#!/bin/bash
if [[ $SUBDIR == $build_platform ]]
then
  if [ -e ${QLIC}/kc.lic ] || [ -e ${QLIC}/k4.lic ]
  then
    tests/test.sh
  else
    echo No kdb+, no tests;
  fi
else
 echo cross compile, no tests
fi
