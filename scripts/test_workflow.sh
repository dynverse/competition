rm -rf test_tmp
mkdir test_tmp

LOCAL=$(pwd)/test_tmp/
MOUNT=/ti

docker run -v $LOCAL:$MOUNT -w $MOUNT dynverse/dyntoy --model linear


mkdir $LOCAL/output_r
docker run -v $LOCAL:$MOUNT dynverse/r_example $MOUNT/dataset.h5 $MOUNT/output_r/
docker run -v $LOCAL:$MOUNT dynverse/convert_output --dataset $MOUNT/dataset.h5 --output_folder $MOUNT/output_r/ --model $MOUNT/model_r.h5

docker run -v $LOCAL:$MOUNT dynverse/ti_slingshot


mkdir $LOCAL/output_python
docker run -v $LOCAL:$MOUNT -w $MOUNT dynverse/python_example $MOUNT/dataset.h5 $MOUNT/output_python/
docker run -v $LOCAL:$MOUNT -w $MOUNT dynverse/convert_output --dataset $MOUNT/dataset.h5 --output_folder $MOUNT/output_python/ --model $MOUNT/model_python.h5

mkdir $LOCAL/output_julia
docker run -v $LOCAL:$MOUNT -w $MOUNT dynverse/julia_example $MOUNT/dataset.h5 $MOUNT/output_julia/
docker run -v $LOCAL:$MOUNT -w $MOUNT dynverse/convert_output --dataset $MOUNT/dataset.h5 --output_folder $MOUNT/output_julia/ --model $MOUNT/model_julia.h5


docker run -v $LOCAL:$MOUNT -w $MOUNT dynverse/convert_output --dataset $MOUNT/dataset.h5 --output_folder $MOUNT/output_r/ --model $MOUNT/model.h5


docker run -v $LOCAL:/ti/ dynverse/dyneval --goldstandard $MOUNT/goldstandard.h5 --model $MOUNT/model.h5 --output $MOUNT/scores.json


cd ../
