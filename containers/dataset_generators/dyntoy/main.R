#!/usr/local/bin/Rscript

library(optparse)
library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(dyntoy)

parser <-
  OptionParser(usage = paste0("LOCAL=/path/to/folder; MOUNT=/ti; docker run -v $LOCAL:$MOUNT dynverse/dyneval")) %>%
  add_option("--model", type = "character", help = "The model, such as linear, bifurcating or tree", default = "linear") %>%
  add_option("--num_cells", type = "integer", help = "Number of cells", default = 200) %>%
  add_option("--num_features", type = "integer", help = "Number of features (genes)", default = 100) %>%
  add_option("--output_goldstandard", type = "character", help = "Filename for the goldstandard, example: $MOUNT/dataset.h5. Will be a json file containing the scores.", default = "goldstandard.h5") %>%
  add_option("--output_dataset", type = "character", help = "Filename for the dataset, example: $MOUNT/dataset.h5. Will be a json file containing the scores.", default = "dataset.h5")

parsed_args <- parse_args(parser, args = commandArgs(trailingOnly = TRUE))

if (any(sapply(parsed_args[c("output_goldstandard", "output_dataset")], is.null))) {
  stop("output arguments are mandatory")
}

# read dataset and model
trajectory <- dyntoy::generate_dataset(
  model = parsed_args$model,
  num_cells = parsed_args$num_cells,
  num_features = parsed_args$num_features
)

goldstandard <- trajectory
dataset <- trajectory[c("cell_ids", "expression", "counts")]

# write output
dynutils::write_h5(goldstandard, parsed_args$output_goldstandard)
dynutils::write_h5(dataset, parsed_args$output_dataset)
