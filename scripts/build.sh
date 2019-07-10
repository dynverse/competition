## EXAMPLE GENERATOR
FOLDER="containers/dataset_generators/dyntoy/"
TAG="dynverse/dyntoy"

chmod +x $FOLDER/main.R
docker build -t $TAG $FOLDER

docker push $TAG

## R EXAMPLE
FOLDER="containers/methods/r/"
TAG="dynverse/r_example"

chmod +x $FOLDER/main.R
docker build -t $TAG $FOLDER

## PYTHON EXAMPLE
FOLDER="containers/methods/python/"
TAG="dynverse/python_example"

chmod +x $FOLDER/main.py
docker build -t $TAG $FOLDER

## JULIA EXAMPLE
FOLDER="containers/methods/julia/"
TAG="dynverse/julia_example"

chmod +x $FOLDER/main.jl
docker build -t $TAG $FOLDER

## SCALA EXAMPLE
FOLDER="containers/methods/scala-spark/"
TAG="dynverse/scalaspark_example"

docker build -t $TAG $FOLDER

## CONVERTOR CONTAINER
FOLDER="containers/convertors/output/"
TAG="dynverse/convert_output"

chmod +x $FOLDER/main.R
docker build -t $TAG $FOLDER

docker push $TAG

## EVALUATION CONTAINER
FOLDER="containers/evaluators/dyneval/"
TAG="dynverse/dyneval"

chmod +x $FOLDER/main.R
docker build -t $TAG $FOLDER

docker push $TAG

## TC-SCORER
FOLDER="containers/tc-scorer/"
TAG="dynverse/tc-scorer"
VERSION=0.1

chmod +x $FOLDER/main.R
chmod +x $FOLDER/aggregate-scores.R
docker build -t $TAG:$VERSION $FOLDER

docker push $TAG:$VERSION
