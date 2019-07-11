Topcoder single-cell trajectory inference competition
================

## Biological background

Cells are constantly changing based on external and internal stimuli.
These can include:

  - Cell differentiation, a process where cells go from a more stem-cell
    like state to a specialized state
  - Cell division, a process where cells replicate their DNA and split
    into two new cells
  - Cell activation, a process where cells are activated by their
    environment and react to it

There are several techniques to measure the current state of a cell. In
this competition we focus on the transcriptome of a cell, which can be
analyzed with *single-cell RNA-seq* technologies. In the recent years
these techniques have scaled up to being able to assess the expression
(i.e. activity) of thousands of genes within tens of thousands of cells.

The state of a cell often changes gradually, and so does its
transcriptome. If you profile different cells that are all at different
stages, you can reconstruct the paths that cells take. These paths are
called trajectories, and the methods that infers them from single-cell
data are called trajectory inference (TI) methods. An example of such a
trajectory is given below, visualized on a 2D dimensionality reduction
of a single-cell expression dataset.

![](description_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

The topology of a trajectory can range from very simple (linear or
circular) to very complex (trees or disconnected graphs).

![](description_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

## Problem description

You are given the expression of thousands of genes within thousands of
cells. This expression is given both in raw format (counts matrix) as in
a normalized format (expression matrix). The goal is to construct a
topology that represents these cells, and to place these cells on the
correct locations along this topology.

![](docs/img/input_output.png)

The topology is a graph structure, in this context called the milestone
network as it connects “milestones” that cells pass through. Each edge
within the milestone network can only be present once, and every edge
has an associated length, which indicates how much the gene expression
has changed between two milestones.

The cells are placed at a particular position of this milestone network.
We represent this as “progressions”, where each cell is assigned to an
edge and a percentage indicating how far it has progressed in that edge.

### Quick start

To get started, check out the examples we provided for different
programming languages. These examples infer a simple linear trajectory
by using the first component of a principal component analysis as
progression.

| Example                                                               | Dockerfile                                                                      | Input                                                                                  | Onput                                                                                  |
| :-------------------------------------------------------------------- | :------------------------------------------------------------------------------ | :------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------- |
| [R](containers/tc-submissions/submission-r/code/)                     | [Dockerfile](containers/tc-submissions/submission-r/code//Dockerfile)           | [main.R\#5](containers/tc-submissions/submission-r/code/main.R#L5)                     | [main.R\#51](containers/tc-submissions/submission-r/code/main.R#L51)                   |
| [Python](containers/tc-submissions/submission-python/code/)           | [Dockerfile](containers/tc-submissions/submission-python/code//Dockerfile)      | [main.py\#9](containers/tc-submissions/submission-python/code/main.py#L9)              | [main.py\#51](containers/tc-submissions/submission-python/code/main.py#L51)            |
| [Julia](containers/tc-submissions/submission-julia/code/)             | [Dockerfile](containers/tc-submissions/submission-julia/code//Dockerfile)       | [main.jl\#9](containers/tc-submissions/submission-julia/code/main.jl#L9)               | [main.jl\#58](containers/tc-submissions/submission-julia/code/main.jl#L58)             |
| [Scala-Spark](containers/tc-submissions/submission-scala-spark/code/) | [Dockerfile](containers/tc-submissions/submission-scala-spark/code//Dockerfile) | [Main.scala\#28](containers/tc-submissions/submission-scala-spark/code/Main.scala#L28) | [Main.scala\#67](containers/tc-submissions/submission-scala-spark/code/Main.scala#L67) |

### Detailed description

You have to write a docker container that will read in the input files
and write out the output files in a mounted folder. This container has
to have an entrypoint that will ready in two command-line arguments: the
first contains the location of the input file, and the second the
location of the output folder. Examples of Dockerfiles (and associated
entrypoints) are provided for
[R](containers/tc-submissions/submission-r/code//Dockerfile),
[Python](containers/tc-submissions/submission-python/code//Dockerfile),
[Julia](containers/tc-submissions/submission-julia/code//Dockerfile) and
[Scala-Spark](containers/tc-submissions/submission-scala-spark/code//Dockerfile).
Make sure to specify the entrypoint using the JSON notation as is shown
in the examples.

The input file is an HDF5 file, which contains two matrices: the counts
(`/data/counts`) and expression (`/data/expression`). These matrices
contain the expression of genes (columns) within hundreds to millions of
cells (rows). Example HDF5 files are present in the [examples inputs
folder](examples/inputs) (*dataset.h5*).

Because the data is very sparse, the matrices are stored inside a sparse
format: [Compressed sparse column format
(CSC)](https://docs.scipy.org/doc/scipy/reference/generated/scipy.sparse.csc_matrix.html).
We provided an example to read in these matrices for
[R](containers/tc-submissions/submission-r/code/main.R#L5),
[Python](containers/tc-submissions/submission-python/code/main.py#L9),
[Julia](containers/tc-submissions/submission-julia/code/main.jl#L9) and
[Scala-Spark](containers/tc-submissions/submission-scala-spark/code/Main.scala#L28)
. This format stores three sparse array, *i*, *p* and *x*. *x* contains
the actual values, *i* contains the row index for each value, and *p*
contains which of the elements of *i* and *x* are in each column (i.e.
*p*<sub><i>j</i></sub> until *p*<sub><i>j+1</i></sub> are the values
from *x* and *i* that are in column *j*). We also provide the
*rownames*, that correspond to cell identifiers, and the *dims*, the
dimensions of the matrix.

As output you have to provide two files. The *milestone\_network.csv* is
a table containing how milestones are connected (*from* and *to*) and
the lengths of these connections (*length*). The *progressions.csv*
contains for each cell (*cell\_id*) where it is located along this
topology (*from*, *to* and *percentage* ∈ \[0, 1\]). Both outputs have
to be saved as a comma separated file without an index but with header.
Example csv files are present in the [examples outputs
folder](examples/outputs) (*progressions.csv* and
*milestone\_network.csv*).

We provided an example to save these two objects for
[R](containers/tc-submissions/submission-r/code/main.R#L51),
[Python](containers/tc-submissions/submission-python/code/main.py#L51),
[Julia](containers/tc-submissions/submission-julia/code/main.jl#L58) and
[Scala-Spark](containers/tc-submissions/submission-scala-spark/code/Main.scala#L67)

## Evaluation

Your output will be compared to the known (or expected) trajectory
within both synthetic and real datasets. This is done using five
metrics, each contributing (on average) 1/5th to the overall score.

  - Similarity between the topology
  - Similarity between the position of cells on particular branches
  - Similarity between the relative positions of cells within the
    trajectory
  - Similarity between features that change along the trajectory
  - Running time: The average running time in seconds, through a log
    transformation, and scaled so that ⩽ 1 second has score 1, and ⩾ 1
    hour has score 0.

The first four metrics are aggregated for each dataset using a geometric
mean. That means that low values (i.e. close to zero) for any of the
metrics results in a low score overall. They are weighted so that:

  - A slight difference in performance for more difficult datasets is
    more important than an equally slight difference for an easy dataset
  - Datasets with a more rare trajectory type (e.g. tree) are given
    relatively more weight than frequent topologies (e.g. linear)

## Evaluating a method locally

You can run a method and the evaluation locally using the script
[scripts/example.sh](scripts/example.sh):

``` bash
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
```

## Exploring the output

You can use the `dynverse/convertor` container to convert the output of
a method to the format that [dynverse](https://dynverse.org)
understands. This can be useful to visualize and inspect the output of a
method in R. For example:

``` r
# First time users should run this:
# install.packages("devtools")
# devtools::install_github("dynverse/dyno")

library(dyno, quietly = TRUE)
```

    ## 
    ## Attaching package: 'dynplot'

    ## The following objects are masked from 'package:dynplot2':
    ## 
    ##     empty_plot, example_bifurcating, example_disconnected,
    ##     example_linear, example_tree, get_milestone_palette_names,
    ##     theme_clean, theme_graph

``` r
# load in the model and groundtruth
model <- dynutils::read_h5("examples/outputs/linear/model.h5")
dataset <- dynutils::read_h5("examples/inputs/linear.h5")
groundtruth <- dynutils::read_h5("examples/ground-truths/linear.h5")

# add a dimensionality reduction to the ground truth using landmark MDS
groundtruth <- groundtruth %>% add_dimred(dyndimred::dimred_landmark_mds)
dimred <- groundtruth$dimred

# also infer a trajectory using one of the current state-of-the-art methods, e.g. slingshot
model2 <- infer_trajectory(groundtruth, dynmethods::ti_slingshot())

# plot both the groundtruth and model
patchwork::wrap_plots(
  dynplot::plot_dimred(groundtruth, dimred = dimred) + ggtitle("Ground truth"),
  dynplot::plot_dimred(model, dimred = dimred) + ggtitle("Model from your method"),
  dynplot::plot_dimred(model2, dimred = dimred) + ggtitle("Model of slingshot")
)
```

    ## Coloring by milestone

    ## Using milestone_percentages from trajectory

    ## Coloring by milestone

    ## Using milestone_percentages from trajectory

    ## Coloring by milestone

    ## Using milestone_percentages from trajectory

![](description_files/figure-gfm/unnamed-chunk-8-1.png)<!-- -->

## Additional information

### Normalization of datasets

Single-cell RNA-seq datasets are often normalized so that the expression
of different cells is more comparable. This can involve

  - Dividing the counts of each cell by the total number of counts per
    cell
  - Log2 normalisation
  - Many more complex approaches that are available in packages such as
    [scran](https://bioconductor.org/packages/release/bioc/html/scran.html)
    (R/Bioconductor),
    [sctransform](https://github.com/ChristophH/sctransform) (R) and
    [scanpy](https://scanpy.readthedocs.io/en/stable/) (Python).

Whether normalisation is necessary depends on what you do with the data.
For example, it will be more important if you calculate some euclidean
distances, but useless if you calculate rank correlations.

### Difficulty of datasets

There is a broad gradient of difficulty among the datasets. Some
datasets could be solved by pen and paper, while others may almost be
impossible to correctly define the trajectory. Don’t try to optimise a
method for all datasets, but rather try to learn from datasets that are
next in your “difficulty” frontier.

You can get an overview of the estimated difficulty of a dataset in the
[datasets/training/difficulties.csv](datasets/training/difficulties.csv).
The `overall_mean` columns gives you the difficulty rating for all
scores combined (the lower the more difficult). One factor in the
difficulty is the kind of trajectory topology: linear and bifurcating
datasets are often easier than graph or tree datasets.

![](datasets/training/difficulty.png)

## Further reading

[**A comparison of single-cell trajectory inference methods
(2019)**](http://em.rdcu.be/wf/click?upn=lMZy1lernSJ7apc5DgYM8RY2IzMp2w2A3DvtZzsJuXQ-3D_pHvsHvhfQaoNOkiaWNdPTjEYljnHm5S7EpH3PfJ5poSURd1eHm2H4ZrZffcWuk-2FVAindB7MLQFXJP7SDz5ymc76HIgI5DN8-2FH4-2F0TSTEWycfk1kcZnplv69A2DcepMUlm91KK1RoNKzOirYAwv80Lt5hqKoaTim-2B0sBTAo6vy56EGHpLul12jZ1a9APM7IdmLQr043l6b9bkFfA7ziZOCz0RTd1L7AMKVtxjW5BlMgjfDbYlrbJoP98nzAtGp0amLM5xaU0-2FmLwX0enc7rmd9Q-3D-3D):
Benchmarking study of current state-of-the-art methods for trajectory
inference. <https://doi.org/10.1038/s41587-019-0071-9>

[**Concepts and limitations for learning developmental trajectories from
single cell genomics (2019)**](https://doi.org/10.1242/dev.170506): A
review on trajectory inference algorithms
