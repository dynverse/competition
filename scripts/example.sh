# download the datasets from ..... and put them inside the datasets/training/ folder

# build the method container
CONTAINER_FOLDER=containers/tc-submissions/submission-python/code
TAG=dynverse/python_example

chmod +x $CONTAINER_FOLDER/main.py
docker build -t $TAG $CONTAINER_FOLDER

# create a folder to store the output and scores
OUTPUT_FOLDER=$(pwd)/results
OUTPUT_MOUNT="-v $OUTPUT_FOLDER:/outputs/"
mkdir $OUTPUT_FOLDER

# define the folders where the data is stored
DATA_FOLDER=$(pwd)/datasets/training/inputs
GT_FOLDER=$(pwd)/datasets/training/ground-truths

DATA_MOUNT="-v $DATA_FOLDER:/data/"
GT_MOUNT="-v $GT_FOLDER:/ground-truths"
WEIGHTS_MOUNT="-v $(pwd)/datasets/training/weights.csv:/weights.csv"
DIFFICULTIES_MOUNT="-v $(pwd)/datasets/training/difficulties.csv:/difficulties.csv"

# run on one dataset ------------------------------------------------------------------
DATASET_ID=real-gold-aging-hsc-old_kowalczyk

mkdir $OUTPUT_FOLDER/$DATASET_ID
/usr/bin/time -o $OUTPUT_FOLDER/$DATASET_ID/time.txt -f "%e" \
  docker run $DATA_MOUNT $OUTPUT_MOUNT $TAG \
  /data/${DATASET_ID}.h5 /outputs/${DATASET_ID}/
ls $OUTPUT_FOLDER/$DATASET_ID

# run on many datasets ----------------------------------------------------------------
GT_LOCATIONS=($GT_FOLDER/*.h5)

ENTRYPOINT=$(docker inspect --format='{{join .Config.Entrypoint " "}}' $TAG)

# start the container
docker stop method && docker rm method
docker run --name method --entrypoint bash --rm -d -i -t $DATA_MOUNT $OUTPUT_MOUNT $TAG

# loop over every dataset (as an example we only do it for the first 10 here)
# we remove (potential) previous output and time the execution
for GT_LOCATION in ${GT_LOCATIONS[@]:1:10}; do
  DATASET_ID=$(basename -s .h5 $GT_LOCATION)
  echo $DATASET_ID
  DATASET_OUTPUT_FOLDER=$OUTPUT_FOLDER/$DATASET_ID/
  mkdir -p $DATASET_OUTPUT_FOLDER
  rm -rf $DATASET_OUTPUT_FOLDER/*
  /usr/bin/time -o $DATASET_OUTPUT_FOLDER/time.txt -f "%e" \
    docker exec method \
    $ENTRYPOINT /data/${DATASET_ID}.h5 /outputs/${DATASET_ID}/
done

# stop the container
docker stop method

# then evaluate it using the dyneval docker
docker run $DATA_MOUNT $GT_MOUNT $OUTPUT_MOUNT $WEIGHTS_MOUNT $DIFFICULTIES_MOUNT dynverse/tc-scorer:0.1

# the overall score is present in ...
cat $OUTPUT_FOLDER/AGGREGATED_SCORE

# the scores on each dataset can be viewed in
head $OUTPUT_FOLDER/dataset_scores.csv
