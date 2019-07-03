#!/usr/local/bin/python3

import h5py
import sys
import scipy.sparse
import sklearn.decomposition
import pandas as pd

##### Read data #####

# parse location of dataset and output folder
dataset_location = sys.argv[1]
output_folder = sys.argv[2]

# read in sparse matrix
dataset_h5 = h5py.File(dataset_location)
expression_h5 = dataset_h5["data"]["expression"]
expression = scipy.sparse.csc_matrix((
  expression_h5["x"][()],
  expression_h5["i"][()],
  expression_h5["p"][()]),
  expression_h5["dims"][()]
)
cell_ids = expression_h5["rownames"][()].astype(str)

##### Infer a trajectory #####

# do pca
pca = sklearn.decomposition.TruncatedSVD()
pca_transformed = pca.fit_transform(expression)

# select first principal component to construct a linear trajectory
# the component is scaled between 0 and 1 to get to a "percentage"
time = pca_transformed[:,1]
time = (time - time.min()) / (time.max() - time.min())

# construct milestone network and progressions
milestone_network = pd.DataFrame({
  "from": ["A"],
  "to": ["B"],
  "length": [1]
})

progressions = pd.DataFrame({
  "cell_id": cell_ids,
  "percentage": time
})
progressions["from"] = "A"
progressions["to"] = "B"

##### Save output #####
milestone_network.to_csv(output_folder + "milestone_network.csv", index = False)
progressions.to_csv(output_folder + "progressions.csv", index = False)
