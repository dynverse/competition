#!/bin/bash

rm /outputs/AGGREGATED_SCORE || true
rm /outputs/dataset_scores.csv || true

for filename in /outputs/*/; do
  test_case=$(basename $filename)
  echo "Scoring" $test_case
  /code/main.R --groundtruth /data/ground-truths/$test_case.h5 \
    --output /outputs/$test_case \
    --output_scores /outputs/$test_case/scores.json
done

echo "Aggregating"

/code/aggregate-scores.R
