#!/usr/local/bin/Rscript

library(hdf5r)

# Read data ---------------------------------------------------------------

# parse location of dataset and output folder
params <- commandArgs(trailingOnly = TRUE)
dataset_location <- params[1]
output_folder <- params[2]

# read in sparse matrix
dataset_h5 <- H5File$new(dataset_location)

expression_h5 <- dataset_h5[["data"]][["expression"]]
expression <- Matrix::sparseMatrix(
  i = expression_h5[["i"]]$read(),
  p = expression_h5[["p"]]$read(),
  x = expression_h5[["x"]]$read(),
  dims = expression_h5[["dims"]]$read(),
  dimnames = list(
    rownames = expression_h5[["rownames"]]$read(),
    colnames = expression_h5[["colnames"]]$read()
  ),
  index1 = FALSE
)

# Infer a trajectory ------------------------------------------------------

# do pca
pca <- prcomp(expression)

# select first principal component to construct a linear trajectory
# the component is scaled between 0 and 1 to get to a "percentage"
time <- pca$x[, "PC1"]
time <- (time - min(time)) / (max(time) - min(time))

# construct milestone network and progressions
milestone_network <- tibble::tibble(
  from = "A",
  to = "B",
  length = 1
)
progressions <- tibble::tibble(
  from = "A",
  to = "B",
  cell_id = names(time),
  percentage = time
)

# Save output -------------------------------------------------------------
write.csv(progressions, paste0(output_folder, "progressions.csv"), row.names = FALSE)
write.csv(milestone_network, paste0(output_folder, "milestone_network.csv"), row.names = FALSE)
