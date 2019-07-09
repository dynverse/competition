#!/bin/bash
input=$1
output=$2
for filename in $input/*.h5; do
  outdir=$output/$(basename -s .h5 $filename)/
  mkdir $outdir
  /code/main.py $filename $outdir
done
