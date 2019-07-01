FOLDER="containers/dataset_generators/dyntoy/"
TAG="dynverse/dyntoy"

chmod +x $FOLDER/main.R
docker build -t $TAG $FOLDER



FOLDER="containers/methods/R/"
TAG="dynverse/r_example"

chmod +x $FOLDER/main.R
docker build -t $TAG $FOLDER




FOLDER="containers/methods/python,/"
TAG="dynverse/python_example"

chmod +x $FOLDER/main.py
docker build -t $TAG $FOLDER
