#!/usr/local/bin/Rscript

library(optparse, quietly = TRUE, warn.conflicts = FALSE)
library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(readr, quietly = TRUE, warn.conflicts = FALSE)
library(dynwrap, quietly = TRUE, warn.conflicts = FALSE)
requireNamespace("hdf5r", quietly = TRUE)

parser <-
  OptionParser(usage = paste0("LOCAL=/path/to/folder; MOUNT=/ti; docker run -v $LOCAL:$MOUNT dynverse/dyneval")) %>%
  add_option("--dataset", type = "character", help = "The dataset file location", default = "/ti/dataset.h5") %>%
  add_option("--output_folder", type = "character", help = "Either the folder containing the output, or the hdf5 file containing the output", default = "/ti/output/") %>%
  add_option("--model", type = "character", help = "The location of the model hdf5 file", default = "/ti/model.h5")

parsed_args <- parse_args(parser, args = commandArgs(trailingOnly = TRUE))

#' @examples
#' parsed_args <- list(dataset = "test_tmp/dataset.h5", output_folder = "test_tmp/output_r", output = "test_tmp/output.h5")

# load dataset (not yet used, may be useful in the future)
dataset <- dynutils::read_h5(parsed_args$dataset)

# check if output_folder is a file
# if so, just copy the file and be done with it
if (fs::is_file(parsed_args$output_folder)) {
  fs::file_copy(parsed_args$output_folder, parsed_args$model)

# otherwise, we process the milestone_network and progressions into a new hdf5 file
} else {
  # load in milestone network and progressions
  milestone_network <- readr::read_csv(
    paste0(parsed_args$output_folder, "/milestone_network.csv"),
    col_types = cols(
      from = col_character(),
      to = col_character(),
      length = col_double()
    )
  )
  milestone_network$directed <- FALSE

  progressions <- readr::read_csv(
    paste0(parsed_args$output_folder, "/progressions.csv"),
    col_types = cols(
      from = col_character(),
      to = col_character(),
      cell_id = col_character(),
      percentage = col_double()
    )
  )

  # construct the dynwrap trajectory object
  trajectory <- wrap_data(
    cell_ids = unique(progressions$cell_id)
  ) %>%
    add_trajectory(
      milestone_network = milestone_network,
      progressions = progressions
    ) %>%
    add_cell_waypoints()

  # write output
  dynutils::write_h5(trajectory, parsed_args$model)

}
