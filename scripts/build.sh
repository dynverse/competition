FOLDER="containers/dataset_generators/dyntoy/"
TAG="dynverse/dyntoy"

chmod +x $FOLDER/main.R
docker build -t $TAG $FOLDER





FOLDER="containers/methods/r/"
TAG="dynverse/r_example"

chmod +x $FOLDER/main.R
docker build -t $TAG $FOLDER





FOLDER="containers/methods/python/"
TAG="dynverse/python_example"

chmod +x $FOLDER/main.py
docker build -t $TAG $FOLDER





FOLDER="containers/methods/julia/"
TAG="dynverse/julia_example"

chmod +x $FOLDER/main.jl
docker build -t $TAG $FOLDER






FOLDER="containers/convertors/output/"
TAG="dynverse/convert_output"

chmod +x $FOLDER/main.R
docker build -t $TAG $FOLDER

docker push $TAG




FOLDER="containers/evaluators/dyneval/"
TAG="dynverse/dyneval"

chmod +x $FOLDER/main.R
docker build -t $TAG $FOLDER

docker push $TAG
