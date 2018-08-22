#!/bin/bash
conda install -q -y anaconda-client
for pack in $(cat packagenames.txt)
do
 anaconda -t $CONDATOKEN upload -l dev $pack
done

