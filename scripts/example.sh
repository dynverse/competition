# download the datasets from ..... and put them inside the datasets/training/ folder

# build the method container
CONTAINER_FOLDER=containers/tc-submissions/submission-r/code
IMAGE=dynverse/python_example

chmod +x $CONTAINER_FOLDER/main.py
docker build -t $IMAGE $CONTAINER_FOLDER

# create a folder to store the output and scores
OUTPUT_FOLDER=$(pwd)/results
OUTPUT_MOUNT="-v $OUTPUT_FOLDER:/outputs/"
mkdir $OUTPUT_FOLDER

# define the folders where the data is stored
DATA_FOLDER=$(pwd)/datasets/training/
DATA_MOUNT="-v $DATA_FOLDER:/data/"

# run on one dataset ------------------------------------------------------------------
# this uses the default entrypoint
DATASET_ID=real-gold-aging-hsc-old_kowalczyk

mkdir $OUTPUT_FOLDER/$DATASET_ID
/usr/bin/time -o $OUTPUT_FOLDER/$DATASET_ID/time.txt -f "%e" \
  docker run $DATA_MOUNT $OUTPUT_MOUNT $IMAGE \
  /data/inputs/${DATASET_ID}.h5 /outputs/${DATASET_ID}/
ls $OUTPUT_FOLDER/$DATASET_ID

# run on many datasets ----------------------------------------------------------------
# this uses the runner script (scripts/runner.sh)
sh scripts/runner.sh $DATA_FOLDER $OUTPUT_FOLDER $IMAGE

# then evaluate it using the dyneval docker
docker run $DATA_MOUNT $OUTPUT_MOUNT dynverse/tc-scorer:0.3

# the overall score is present in ...
cat $OUTPUT_FOLDER/AGGREGATED_SCORE

# the scores on each dataset can be viewed in
head $OUTPUT_FOLDER/dataset_scores.csv
