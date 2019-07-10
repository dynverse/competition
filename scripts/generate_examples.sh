rm -rf examples
mkdir examples

# input

mkdir examples/inputs/
mkdir examples/ground-truths

INPUT_FOLDER=$(pwd)/examples/inputs/
GT_FOLDER=$(pwd)/examples/ground-truths/
MOUNT=/ti
GT_MOUNT="-v $GT_FOLDER:/gt"

create_example() {
  docker run -v $INPUT_FOLDER:$MOUNT $GT_MOUNT  -w $MOUNT dynverse/dyntoy --model $EXAMPLE_ID --output_groundtruth /gt/$EXAMPLE_ID.h5 --output_dataset $EXAMPLE_ID.h5
}

EXAMPLE_ID=linear create_example
EXAMPLE_ID=bifurcating create_example
EXAMPLE_ID=tree create_example
EXAMPLE_ID=disconnected create_example

Rscript - <<EOF
library(dplyr)
library(readr)
library(tidyr)

metrics <- c("correlation", "F1_branches", "featureimp_wcor", "him")
dataset_ids <- c("linear", "bifurcating", "tree", "disconnected")

crossing(
  dataset_id = dataset_ids,
  metric = metrics,
  type = c("mean", "sd")
) %>%
  mutate(score = runif(n())) %>%
  spread(type, score) %>%
  write_csv("examples/difficulties.csv")

tibble(
  dataset_id = dataset_ids,
  weight = runif(length(dataset_ids))
) %>%
  mutate(weight = weight / sum(weight)) %>%
  write_csv("examples/weights.csv")
EOF

# output
mkdir examples/outputs/

create_output() {
  mkdir $OUTPUT_FOLDER/$EXAMPLE_ID
  docker run -v $INPUT_FOLDER/:$MOUNT_INPUT \
    -v $OUTPUT_FOLDER/$EXAMPLE_ID/:$MOUNT_OUTPUT \
    -w $MOUNT \
    dynverse/r_example \
    $MOUNT_INPUT/$EXAMPLE_ID.h5 $MOUNT_OUTPUT/
}

OUTPUT_FOLDER=$(pwd)/examples/outputs/
MOUNT_INPUT=/input
MOUNT_OUTPUT=/output

EXAMPLE_ID=linear create_output
EXAMPLE_ID=bifurcating create_output
EXAMPLE_ID=tree create_output
EXAMPLE_ID=disc onnected create_output

# scores
docker run \
  -v $(pwd)/examples/difficulties.csv:/difficulties.csv \
  -v $(pwd)/examples/weights.csv:/weights.csv \
  -v $(pwd)/examples/ground-truths:/ground-truths \
  -v $(pwd)/examples/outputs:/outputs \
  dynverse/tc-scorer:0.1 10000

# score aggregate
docker run -v $(pwd)/examples:/ti \
  -w /ti \
  single-cell-scorer 10000
