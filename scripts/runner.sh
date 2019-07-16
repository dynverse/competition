DATA_FOLDER=$1
OUTPUT_FOLDER=$2
IMAGE=$3

DATA_MOUNT="-v $DATA_FOLDER:/data/"
OUTPUT_MOUNT="-v $OUTPUT_FOLDER:/outputs/"

# find the entrypoint so that we can call it repeatedly
ENTRYPOINT=$(docker inspect --format='{{join .Config.Entrypoint " "}}' $IMAGE)

# find all gold standards
DATASET_LOCATIONS=($DATA_FOLDER/inputs/*.h5)
echo $DATASET_LOCATIONS

# start the container as a detached session
CONTAINER=$(docker run --entrypoint bash --rm -d -i -t $DATA_MOUNT $OUTPUT_MOUNT $IMAGE)

# make sure this container is removed if the script errors
set -e
function cleanup {
  docker stop $CONTAINER
}
trap cleanup EXIT

# loop over every dataset (as an example we only do it for the first 10 here)
# we remove (potential) previous output and time the execution
for DATASET_LOCATION in ${DATASET_LOCATIONS[@]:1:10}; do
  DATASET_ID=$(basename -s .h5 $DATASET_LOCATION)
  echo $DATASET_ID
  DATASET_OUTPUT_FOLDER=$OUTPUT_FOLDER/$DATASET_ID/
  mkdir -p $DATASET_OUTPUT_FOLDER
  rm -rf $DATASET_OUTPUT_FOLDER/*
  /usr/bin/time -o $DATASET_OUTPUT_FOLDER/time.txt -f "%e" \
    docker exec $CONTAINER \
    $ENTRYPOINT /data/inputs/${DATASET_ID}.h5 /outputs/${DATASET_ID}/
done

# stop the container
docker stop $CONTAINER
