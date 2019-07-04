#!/usr/local/julia/bin/julia

using SparseArrays
using HDF5
using MultivariateStats
using DataFrames
using CSV

##### Read data #####

# parse location of dataset and output folder

dataset_location = ARGS[1]
output_folder = ARGS[2]

# read in sparse matrix
data = h5open(dataset_location, "r")
expression_h5 = read(data["data"]["expression"])
close(data)

p = expression_h5["p"] .+ 1
i = expression_h5["i"] .+ 1
expression = SparseMatrixCSC(
    expression_h5["dims"][1],
    expression_h5["dims"][2],
    p,
    i,
    expression_h5["x"]
)

cell_ids = expression_h5["rownames"]

##### Infer a trajectory #####

# do pca
pca = fit(KernelPCA, expression; maxoutdim=1)
pca_transformed = transform(pca, expression)

# select first principal component to construct a linear trajectory
# the component is scaled between 0 and 1 to get to a "percentage"
time = pca_transformed[1, :]
time = (time .- minimum(time)) ./ (maximum(time) - minimum(time))

# construct milestone network and progressions
milestone_network = DataFrame(
    from = "A",
    to = "B",
    length = 1
)

progressions = DataFrame(
    from = "A",
    to = "B",
    cell_id = cell_ids,
    percentage = time
)

##### Save output #####
CSV.write(output_folder * "progressions.csv", progressions)
CSV.write(output_folder * "milestone_network.csv", milestone_network)
