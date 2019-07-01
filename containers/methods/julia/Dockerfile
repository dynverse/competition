FROM julia:1.1.1

RUN apt-get update && apt-get install -y libhdf5-serial-dev

RUN julia -e 'using Pkg;Pkg.add(["SparseArrays", "HDF5", "MultivariateStats", "DataFrames", "CSV"])'
RUN julia -e 'using SparseArrays; using HDF5; using MultivariateStats; using DataFrames; using CSV'

COPY main.jl /code/

ENTRYPOINT ["/code/main.jl"]
