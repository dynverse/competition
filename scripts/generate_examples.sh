rm -rf examples
mkdir examples

LOCAL_OUTPUT=$(pwd)/examples/
MOUNT=/ti

EXAMPLE_ID=linear
mkdir $LOCAL_OUTPUT/$EXAMPLE_ID
docker run -v $LOCAL_OUTPUT/$EXAMPLE_ID:$MOUNT -w $MOUNT dynverse/dyntoy --model $EXAMPLE_ID


EXAMPLE_ID=bifurcating
mkdir $LOCAL_OUTPUT/$EXAMPLE_ID
docker run -v $LOCAL_OUTPUT/$EXAMPLE_ID:$MOUNT -w $MOUNT dynverse/dyntoy --model $EXAMPLE_ID


EXAMPLE_ID=tree
mkdir $LOCAL_OUTPUT/$EXAMPLE_ID
docker run -v $LOCAL_OUTPUT/$EXAMPLE_ID:$MOUNT -w $MOUNT dynverse/dyntoy --model $EXAMPLE_ID


EXAMPLE_ID=disconnected
mkdir $LOCAL_OUTPUT/$EXAMPLE_ID
docker run -v $LOCAL_OUTPUT/$EXAMPLE_ID:$MOUNT -w $MOUNT dynverse/dyntoy --model $EXAMPLE_ID
