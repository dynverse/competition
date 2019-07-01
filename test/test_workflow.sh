mkdir test_tmp

cd test_tmp

LOCAL=$(pwd)
MOUNT=/ti

docker run -v $LOCAL:$MOUNT -w $MOUNT --user 1000:1000 dynverse/dyntoy --model linear

docker run -v $LOCAL:$MOUNT -w $MOUNT --user 1000:1000 dynverse/r_example $MOUNT/dataset.h5 $MOUNT/







LOCAL=$(pwd); MOUNT=/ti; docker run -v $LOCAL:$MOUNT -w $MOUNT dynverse/dyneval
