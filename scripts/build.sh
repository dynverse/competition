## EXAMPLE GENERATOR
FOLDER="containers/dataset_generators/dyntoy/"
TAG="dynverse/dyntoy"

chmod +x $FOLDER/main.R
docker build -t $TAG $FOLDER

docker push $TAG

## R EXAMPLE
FOLDER="containers/tc-submissions/submission-r/code"
TAG="dynverse/r_example"

chmod +x $FOLDER/main.R
docker build -t $TAG $FOLDER

## PYTHON EXAMPLE
FOLDER="containers/tc-submissions/submission-python/code"
TAG="dynverse/python_example"

chmod +x $FOLDER/main.py
docker build -t $TAG $FOLDER

## JULIA EXAMPLE
FOLDER="containers/tc-submissions/submission-julia/code"
TAG="dynverse/julia_example"

chmod +x $FOLDER/main.jl
docker build -t $TAG $FOLDER

## SCALA EXAMPLE
FOLDER="containers/tc-submissions/submission-scala-spark/code"
TAG="dynverse/scalaspark_example"

docker build -t $TAG $FOLDER

## CONVERTOR CONTAINER
FOLDER="containers/convertors/output/"
TAG="dynverse/convert_output"

chmod +x $FOLDER/main.R
docker build -t $TAG $FOLDER

docker push $TAG

## TC-SCORER
FOLDER="containers/tc-scorer/"
TAG="dynverse/tc-scorer"
VERSION=0.3

chmod +x $FOLDER/main.R
chmod +x $FOLDER/aggregate-scores.R
docker build -t $TAG:$VERSION $FOLDER

docker push $TAG:$VERSION


## SUBMISSIONS
pushd containers/tc-submissions/submission-python/ && zip -r ../submission-python.zip code && popd
pushd containers/tc-submissions/submission-scala-spark/ && zip -r ../submission-scala-spark.zip code && popd
pushd containers/tc-submissions/submission-julia/ && zip -r ../submission-julia.zip code && popd
pushd containers/tc-submissions/submission-r/ && zip -r ../submission-r.zip code && popd
