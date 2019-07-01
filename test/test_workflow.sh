

rm -rf test_tmp
mkdir test_tmp

cd test_tmp

LOCAL=$(pwd)
MOUNT=/ti

docker run -v $LOCAL:$MOUNT -w $MOUNT dynverse/dyntoy --model linear


cp $LOCAL/dataset.h5 $LOCAL/dataset2.h5
mkdir $LOCAL/output_r
docker run -v $LOCAL:$MOUNT -w $MOUNT dynverse/r_example $MOUNT/dataset2.h5 $MOUNT/output_r/


mkdir $OUTPUT_FOLDER/output_python
docker run -v $LOCAL:$MOUNT -w $MOUNT dynverse/python_example $MOUNT/dataset2.h5 $MOUNT/output_python/
docker run -v $LOCAL:$MOUNT -w $MOUNT dynverse/convert_output --dataset $MOUNT/dataset.h5 --output_folder $MOUNT/output_python/ --model $MOUNT/model_python.h5

mkdir $OUTPUT_FOLDER/output_julia
docker run -v $LOCAL:$MOUNT -w $MOUNT dynverse/python_example $MOUNT/dataset2.h5 $MOUNT/output_python/
docker run -v $LOCAL:$MOUNT -w $MOUNT dynverse/convert_output --dataset $MOUNT/dataset.h5 --output_folder $MOUNT/output_python/ --model $MOUNT/model_python.h5


docker run -v $LOCAL:$MOUNT -w $MOUNT dynverse/convert_output --dataset $MOUNT/dataset.h5 --output_folder $MOUNT/output_r/ --model $MOUNT/model.h5


docker run -v $LOCAL:/ti/ dynverse/dyneval --goldstandard $MOUNT/goldstandard.h5 --model $MOUNT/model.h5 --output $MOUNT/scores.json


^cd ../
