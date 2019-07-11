#!/bin/bash
input=$1
output=$2
entrypoint=$3
for filename in $input/*.h5; do
  outdir=$output/$(basename -s .h5 $filename)/
  mkdir $outdir
  /usr/bin/time -o $outdir/time.txt -f "%e" /code/main.R $filename $outdir
done
