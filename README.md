# Datasets

- dyntoy: toy datasets generated from 
- dyngen: realistic synthetic datasets, generated using dyngen v2
- PROSSTT: realistic synthetic datasets
- real datasets: from dynbenchmark

Goal is to generate relatively large synthetic datasets (~1M cells)

## For competitors

Datasets with

- counts matrix
- expression matrix
- cell ids
- anonymized feature ids

## For scoring

Gold standard with

- trajectory information
- cell waypoints
- feature importances?

# Modules

## Dataset generators

[dyntoy](containers/dataset_generators/dyntoy): dataset generator that can be provided to the comptetitors to generate datasets themselves. It generates two output hdf5 files: the datasets and the gold standard

## Evaluators
[dyneval](containers/dataset_generators/dyneval): compare an output trajectory with the gold standard

## Example methods

Four languages: Java, Scala, R, Python and Julia
R and Python also have a dyncli(py) example

The example showcases the reading of the input, the inference of a very simple trajectory, and writing this out into the correct format

# Documentation

- Biological background
- Input format
- Output format
- Scoring
