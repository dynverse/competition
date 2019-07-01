#!/usr/local/bin/Rscript

library(optparse)
library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(dyneval)

metrics <- dyneval::metrics

parser <-
  OptionParser(usage = paste0("LOCAL=/path/to/folder; MOUNT=/ti; docker run -v $LOCAL:$MOUNT dynverse/dyneval")) %>%
  add_option("--goldstandard", type = "character", help = "Filename of the goldstandard, example: $MOUNT/dataset.h5", default = "/ti/goldstandard.h5") %>%
  add_option("--model", type = "character", help = "Filename of the model, example: $MOUNT/dataset.h5. Is normally created by the dynverse/convert_output container", default = "/ti/model.h5")  %>%
  add_option("--output_scores", type = "character", help = "Filename of the scores, example: $MOUNT/dataset.(h5|loom). Will be a json file containing the scores.", default = "/ti/scores.json") %>%
  add_option("--metrics", type = "character", help = "Which metrics to calculate, example: correlation,him,F1_milestones,featureimp_wcor", default = "correlation,him,F1_milestones,featureimp_wcor")

parsed_args <- parse_args(parser, args = commandArgs(trailingOnly = TRUE))

if (any(sapply(parsed_args[c("goldstandard", "model", "output_scores")], is.null))) {
  stop("dataset, model and output arguments are mandatory")
}

#' @examples
#' parsed_args <- list(goldstandard = "test_tmp/goldstandard.h5", model = "test_tmp/model.h5", output_scores = "test_tmp/scores.json", metrics = "correlation,him,F1_milestones,featureimp_wcor")

# read dataset and model
goldstandard <- dynutils::read_h5(parsed_args$goldstandard)
model <- dynutils::read_h5(parsed_args$model)

metrics <- strsplit(parsed_args$metrics, ",")[[1]]

scores <- dyneval::calculate_metrics(goldstandard, model, metrics = metrics)

# write output
jsonlite::write_json(scores, parsed_args$output_scores)
