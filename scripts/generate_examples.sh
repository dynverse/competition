rm -rf examples
mkdir examples

# input

mkdir examples/input/

INPUT_FOLDER=$(pwd)/examples/input/
MOUNT=/ti

EXAMPLE_ID=linear
mkdir $INPUT_FOLDER/$EXAMPLE_ID
docker run -v $INPUT_FOLDER/$EXAMPLE_ID:$MOUNT -w $MOUNT dynverse/dyntoy --model $EXAMPLE_ID


EXAMPLE_ID=bifurcating
mkdir $INPUT_FOLDER/$EXAMPLE_ID
docker run -v $INPUT_FOLDER/$EXAMPLE_ID:$MOUNT -w $MOUNT dynverse/dyntoy --model $EXAMPLE_ID


EXAMPLE_ID=tree
mkdir $INPUT_FOLDER/$EXAMPLE_ID
docker run -v $INPUT_FOLDER/$EXAMPLE_ID:$MOUNT -w $MOUNT dynverse/dyntoy --model $EXAMPLE_ID


EXAMPLE_ID=disconnected
mkdir $INPUT_FOLDER/$EXAMPLE_ID
docker run -v $INPUT_FOLDER/$EXAMPLE_ID:$MOUNT -w $MOUNT dynverse/dyntoy --model $EXAMPLE_ID

# output
mkdir examples/output/

create_output() {
  mkdir $OUTPUT_FOLDER/$EXAMPLE_ID
  docker run -v $INPUT_FOLDER/$EXAMPLE_ID/:$MOUNT_INPUT \
    -v $OUTPUT_FOLDER/$EXAMPLE_ID/:$MOUNT_OUTPUT \
    -w $MOUNT \
    dynverse/r_example \
    $MOUNT_INPUT/dataset.h5 $MOUNT_OUTPUT/
}

OUTPUT_FOLDER=$(pwd)/examples/output/
MOUNT_INPUT=/input
MOUNT_OUTPUT=/output

EXAMPLE_ID=linear create_output
EXAMPLE_ID=bifurcating create_output
EXAMPLE_ID=tree create_output
EXAMPLE_ID=disconnected create_output
