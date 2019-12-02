#!/usr/local/bin/Rscript

library(hdf5r)
library(purrr)
library(slingshot)
library(tibble)
library(dplyr)
library(SingleCellExperiment)

##### Read data #####

# parse location of dataset and output folder
params <- commandArgs(trailingOnly = TRUE)
dataset_location <- params[1]
output_folder <- params[2]

# read in sparse matrix
dataset_h5 <- H5File$new(dataset_location)

counts_h5 <- dataset_h5[["data"]][["counts"]]
counts <- Matrix::sparseMatrix(
  i = counts_h5[["i"]]$read(),
  p = counts_h5[["p"]]$read(),
  x = counts_h5[["x"]]$read(),
  dims = counts_h5[["dims"]]$read(),
  dimnames = list(
    rownames = counts_h5[["rownames"]]$read(),
    colnames = counts_h5[["colnames"]]$read()
  ),
  index1 = FALSE
)

parameters <- list(
  cluster_method = "pam",
  ndim = 20L,
  shrink = 1L,
  reweight = TRUE,
  reassign = TRUE,
  thresh = 0.001,
  maxit = 10L,
  stretch = 2L,
  smoother = "smooth.spline",
  shrink.method = "cosine"
)

priors <- list()

expression <- log2(counts + 1)

# Infer a trajectory ------------------------------------------------------
start_id <- priors$start_id
end_id <- priors$end_id

#####################################
###        INFER TRAJECTORY       ###
#####################################

#   ____________________________________________________________________________
#   Preprocessing                                                           ####

start_cell <- if (!is.null(start_id)) { sample(start_id, 1) } else { NULL }

# TIMING: done with preproc
checkpoints <- list(method_afterpreproc = as.numeric(Sys.time()))

#   ____________________________________________________________________________
#   Dimensionality reduction                                                ####
ndim <- parameters$ndim
if (ncol(expression) <= ndim) {
  message(paste0(
    "ndim is ", ndim, " but number of dimensions is ", ncol(expression),
    ". Won't do dimensionality reduction."
  ))
  rd <- as.matrix(expression)
} else {
  pca <- irlba::prcomp_irlba(expression, n = ndim)

  # select optimal number of dimensions if ndim is large enough
  if (ndim > 3) {
    # this code is adapted from the expermclust() function in TSCAN
    # the only difference is in how PCA is performed
    # (they specify scale. = TRUE and we leave it as FALSE)
    x <- 1:ndim
    optpoint1 <- which.min(sapply(2:10, function(i) {
      x2 <- pmax(0, x - i)
      sum(lm(pca$sdev[1:ndim] ~ x + x2)$residuals^2 * rep(1:2,each = 10))
    }))

    # this is a simple method for finding the "elbow" of a curve, from
    # https://stackoverflow.com/questions/2018178/finding-the-best-trade-off-point-on-a-curve
    x <- cbind(1:ndim, pca$sdev[1:ndim])
    line <- x[c(1, nrow(x)),]
    proj <- princurve::project_to_curve(x, line)
    optpoint2 <- which.max(proj$dist_ind)-1

    # we will take more than 3 PCs only if both methods recommend it
    optpoint <- max(c(min(c(optpoint1, optpoint2)), 3))
  } else {
    optpoint <- ndim
  }

  rd <- pca$x[, seq_len(optpoint)]
  rownames(rd) <- rownames(expression)
}

#   ____________________________________________________________________________
#   Clustering                                                              ####
# max clusters equal to number of cells
max_clusters <- min(nrow(expression)-1, 10)

# select clustering
if (parameters$cluster_method == "pam") {
  if (nrow(rd) > 10000) {
    warning("PAM (the default clustering method) does not scale well to a lot of cells. You might encounter memory issues. This can be resolved by using the CLARA clustering method, i.e. cluster_method = 'clara'.")
  }
  clusterings <- lapply(3:max_clusters, function(K){
    cluster::pam(rd, K) # we generally prefer PAM as a more robust alternative to k-means
  })
} else if (parameters$cluster_method == "clara") {
  clusterings <- lapply(3:max_clusters, function(K){
    cluster::clara(rd, K) # we generally prefer PAM as a more robust alternative to k-means
  })
}

# take one more than the optimal number of clusters based on average silhouette width
# (max of 10; the extra cluster improves flexibility when learning the topology,
# silhouette width tends to pick too few clusters, otherwise)
wh.cl <- which.max(sapply(clusterings, function(x){ x$silinfo$avg.width })) + 1
labels <- clusterings[[min(c(wh.cl, 8))]]$clustering

start.clus <-
  if(!is.null(start_cell)) {
    labels[[start_cell]]
  } else {
    NULL
  }
end.clus <-
  if(!is.null(end_id)) {
    unique(labels[end_id])
  } else {
    NULL
  }

#   ____________________________________________________________________________
#   Infer trajectory                                                        ####
sds <- slingshot::slingshot(
  rd,
  labels,
  start.clus = start.clus,
  end.clus = end.clus,
  shrink = parameters$shrink,
  reweight = parameters$reweight,
  reassign = parameters$reassign,
  thresh = parameters$thresh,
  maxit = parameters$maxit,
  stretch = parameters$stretch,
  smoother = parameters$smoother,
  shrink.method = parameters$shrink.method
)

start_cell <- apply(slingshot::slingPseudotime(sds), 1, min) %>% sort() %>% head(1) %>% names()
start.clus <- labels[[start_cell]]

# TIMING: done with method
checkpoints$method_aftermethod <- as.numeric(Sys.time())

#   ____________________________________________________________________________
#   Create output                                                           ####

# collect milestone network
lineages <- slingLineages(sds)
lineage_ctrl <- slingParams(sds)

cluster_network <- lineages %>%
  map_df(~ tibble(from = .[-length(.)], to = .[-1])) %>%
  unique() %>%
  mutate(
    length = lineage_ctrl$dist[cbind(from, to)],
    directed = TRUE
  )

# collect dimred
dimred <- reducedDim(sds)

# collect clusters
cluster <- slingClusterLabels(sds)

# collect progressions
adj <- slingAdjacency(sds)
lin_assign <- apply(slingCurveWeights(sds), 1, which.max)

progressions <- map_df(seq_along(lineages), function(l) {
  ind <- lin_assign == l
  lin <- lineages[[l]]
  pst.full <- slingPseudotime(sds, na = FALSE)[,l]
  pst <- pst.full[ind]
  means <- sapply(lin, function(clID){
    stats::weighted.mean(pst.full, cluster[,clID])
  })
  non_ends <- means[-c(1,length(means))]
  edgeID.l <- as.numeric(cut(pst, breaks = c(-Inf, non_ends, Inf)))
  from.l <- lineages[[l]][edgeID.l]
  to.l <- lineages[[l]][edgeID.l + 1]
  m.from <- means[from.l]
  m.to <- means[to.l]

  pct <- (pst - m.from) / (m.to - m.from)
  pct[pct < 0] <- 0
  pct[pct > 1] <- 1

  tibble(cell_id = names(which(ind)), from = from.l, to = to.l, percentage = pct)
})

milestone_network <- cluster_network

##### Save output #####
write.csv(progressions, paste0(output_folder, "progressions.csv"), row.names = FALSE)
write.csv(milestone_network, paste0(output_folder, "milestone_network.csv"), row.names = FALSE)
