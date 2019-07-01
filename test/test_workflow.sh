

rm -rf test_tmp
mkdir test_tmp

cd test_tmp

LOCAL=$(pwd)
MOUNT=/ti

docker run -v $LOCAL:$MOUNT -w $MOUNT dynverse/dyntoy --model linear

cp $LOCAL/dataset.h5 $LOCAL/dataset2.h5
mkdir $LOCAL/output_r
docker run -v $LOCAL:$MOUNT -w $MOUNT dynverse/r_example $MOUNT/dataset2.h5 $MOUNT/output_r/


cp $LOCAL/dataset.h5 $LOCAL/dataset2.h5
mkdir $LOCAL/output_python
docker run -v $LOCAL:$MOUNT -w $MOUNT dynverse/python_example $MOUNT/dataset2.h5 $MOUNT/output_python/


cp $LOCAL/dataset.h5 $LOCAL/dataset2.h5
mkdir $LOCAL/output_julia
docker run -v $LOCAL:$MOUNT -w $MOUNT dynverse/julia_example $MOUNT/dataset2.h5 $MOUNT/output_julia/


cd ../
