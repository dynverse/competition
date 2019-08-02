rm -rf examples
mkdir examples

# input

mkdir examples/data/
mkdir examples/data/inputs/
mkdir examples/data/ground-truths/

INPUT_FOLDER=$(pwd)/examples/data/inputs/
GT_FOLDER=$(pwd)/examples/data/ground-truths/
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
  write_csv("examples/data/difficulties.csv")

tibble(
  dataset_id = dataset_ids,
  weight = runif(length(dataset_ids))
) %>%
  mutate(weight = weight / sum(weight)) %>%
  write_csv("examples/data/weights.csv")
EOF

# output
mkdir examples/outputs/

create_output() {
  mkdir $OUTPUT_FOLDER/$EXAMPLE_ID
  /usr/bin/time -o $OUTPUT_FOLDER/$EXAMPLE_ID/time.txt -f "%e" \
    docker run -v $INPUT_FOLDER/:$MOUNT_INPUT \
    -v $OUTPUT_FOLDER/$EXAMPLE_ID/:$MOUNT_OUTPUT \
    -w $MOUNT \
    dynverse/python_example \
    $MOUNT_INPUT/$EXAMPLE_ID.h5 $MOUNT_OUTPUT/
}

OUTPUT_FOLDER=$(pwd)/examples/outputs/
MOUNT_INPUT=/input
MOUNT_OUTPUT=/output

EXAMPLE_ID=linear create_output
EXAMPLE_ID=bifurcating create_output
EXAMPLE_ID=tree create_output
EXAMPLE_ID=disconnected create_output

# scoring
DATA_FOLDER=$(pwd)/examples/data/
DATA_MOUNT="-v $DATA_FOLDER:/data/"

OUTPUT_FOLDER=$(pwd)/examples/outputs/
OUTPUT_MOUNT="-v $OUTPUT_FOLDER:/outputs/"

docker run $DATA_MOUNT $OUTPUT_MOUNT dynverse/tc-scorer:0.2
