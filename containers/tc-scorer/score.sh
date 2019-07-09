#!/bin/bash

SOLUTION_TIME_MS=$1

rm /outputs/AGGREGATED_SCORE

for filename in /outputs/*; do
  test_case=$(basename $filename)
  /code/converter.R --dataset /inputs/$test_case.h5 \
    --output_folder /outputs/$test_case \
    --model /outputs/$test_case/model.h5
  /code/evaluator.R --groundtruth /ground-truths/$test_case.h5 \
    --model /outputs/$test_case/model.h5 \
    --output_scores /outputs/$test_case/scores.json
done

./aggregate-scores $SOLUTION_TIME_MS
