rm -rf examples
mkdir examples

# input

mkdir examples/input/
mkdir examples/input/groundtruth/

INPUT_FOLDER=$(pwd)/examples/input/
MOUNT=/ti

create_example() {
  docker run -v $INPUT_FOLDER:$MOUNT -w $MOUNT dynverse/dyntoy --model $EXAMPLE_ID --output_groundtruth groundtruth/$EXAMPLE_ID.h5 --output_dataset $EXAMPLE_ID.h5
}

EXAMPLE_ID=linear create_example
EXAMPLE_ID=bifurcating create_example
EXAMPLE_ID=tree create_example
EXAMPLE_ID=disconnected create_example

# output
mkdir examples/output/

create_output() {
  mkdir $OUTPUT_FOLDER/$EXAMPLE_ID
  docker run -v $INPUT_FOLDER/:$MOUNT_INPUT \
    -v $OUTPUT_FOLDER/$EXAMPLE_ID/:$MOUNT_OUTPUT \
    -w $MOUNT \
    dynverse/r_example \
    $MOUNT_INPUT/$EXAMPLE_ID.h5 $MOUNT_OUTPUT/
}

OUTPUT_FOLDER=$(pwd)/examples/output/
MOUNT_INPUT=/input
MOUNT_OUTPUT=/output

EXAMPLE_ID=linear create_output
EXAMPLE_ID=bifurcating create_output
EXAMPLE_ID=tree create_output
EXAMPLE_ID=disconnected create_output
