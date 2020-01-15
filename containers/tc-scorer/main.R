#!/usr/local/bin/Rscript

library(optparse, quietly = TRUE, warn.conflicts = FALSE)
library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(readr, quietly = TRUE, warn.conflicts = FALSE)
library(dynwrap, quietly = TRUE, warn.conflicts = FALSE)
library(dyneval, quietly = TRUE, warn.conflicts = FALSE)
requireNamespace("hdf5r", quietly = TRUE)

metrics <- dyneval::metrics

parser <-
  OptionParser(usage = paste0("LOCAL=/path/to/folder; MOUNT=/ti; docker run -v $LOCAL:$MOUNT dynverse/dyneval")) %>%
  add_option("--groundtruth", type = "character", help = "Filename of the groundtruth, example: $MOUNT/dataset.h5", default = "/ti/groundtruth.h5") %>%
  add_option("--output", type = "character", help = "Filename of the model, or the folder that contains the milestone_network and progressions.", default = "/outputs")  %>%
  add_option("--output_scores", type = "character", help = "Filename of the scores, example: $MOUNT/dataset.(h5|loom). Will be a json file containing the scores.", default = "/ti/scores.json") %>%
  add_option("--metrics", type = "character", help = "Which metrics to calculate, example: correlation,him,F1_milestones,featureimp_wcor", default = "correlation,him,F1_branches") %>%
  add_option("--waypoints", type = "integer", help = "Number of waypoints to take if necessary for a score", default = 100L)

parsed_args <- parse_args(parser, args = commandArgs(trailingOnly = TRUE))

if (any(sapply(parsed_args[c("groundtruth", "output", "output_scores")], is.null))) {
  stop("dataset, output and output_scores arguments are mandatory")
}

#' @examples
#' parsed_args <- list(
#'   groundtruth = "examples/ground-truths/linear.h5",
#'   output = "examples/outputs/linear",
#'   output_scores = "examples/scores/linear.json",
#'   metrics = "correlation,him,F1_branches,featureimp_wcor"
#' )

cat("> Processing output \n")

# read and convert -----------------------------------------------------------
# load dataset (not yet used, may be useful in the future)
groundtruth <- dynutils::read_h5(parsed_args$groundtruth)

# check if output_folder is a file
# if so, just read the file and be done with it
if (fs::is_file(parsed_args$output)) {
  output <- dynutils::read_h5(parsed_args$output)

# otherwise, we process the milestone_network and progressions into a new hdf5 file
} else {
  # load in milestone network and progressions
  milestone_network <- readr::read_csv(
    paste0(parsed_args$output, "/milestone_network.csv"),
    col_types = cols(
      from = col_character(),
      to = col_character(),
      length = col_double()
    )
  )
  milestone_network$directed <- FALSE

  progressions <- readr::read_csv(
    paste0(parsed_args$output, "/progressions.csv"),
    col_types = cols(
      from = col_character(),
      to = col_character(),
      cell_id = col_character(),
      percentage = col_double()
    )
  )

  set.seed(1)

  n_cells <- length(unique(progressions$cell_id))
  if(parsed_args$waypoints == -1) {
    parsed_args$waypoints <- n_cells
  } else {
    parsed_args$waypoints <- min(parsed_args$waypoints, n_cells)
  }

  # construct the dynwrap trajectory object
  output <- wrap_data(
    cell_ids = unique(progressions$cell_id)
  ) %>%
    add_trajectory(
      milestone_network = milestone_network,
      progressions = progressions
    ) %>%
    add_cell_waypoints(num_cells_selected = parsed_args$waypoints)
}

cat("\U2713 Processing output \n")

# score -------------------------------------------------------------------
metrics <- strsplit(parsed_args$metrics, ",")[[1]]

cat("> Scoring \n")

scores <- dyneval::calculate_metrics(groundtruth, output, metrics = metrics)
scores <- scores[metrics]

cat("\U2713 Scoring \n")

# write output
jsonlite::write_json(scores, parsed_args$output_scores)
