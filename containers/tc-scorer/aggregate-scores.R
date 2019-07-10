#!/usr/local/bin/Rscript

# assumes
# - /difficulties.csv exists
# - /ground-truths/... .h5 exists
# - /outputs/.../scores.json exists

library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(readr, quietly = TRUE, warn.conflicts = FALSE)
library(fs, quietly = TRUE, warn.conflicts = FALSE)
library(purrr, quietly = TRUE, warn.conflicts = FALSE)
library(tidyr, quietly = TRUE, warn.conflicts = FALSE)

# for debugging
# base <- "examples/"
base <- ""

output_folder <- paste0(base, "/outputs/")
groundtruths_folder <- paste0(base, "/ground-truths/")
difficulties_path <- paste0(base, "/difficulties.csv")
weights_path <- paste0(base, "/weights.csv")

cat("> Reading scores \n")

difficulties <- read_csv(
  difficulties_path,
  col_types = cols(dataset_id = col_character(), metric = col_character(), mean = col_double(), sd = col_double())
)
weights <- read_csv(
  weights_path,
  col_types = cols(dataset_id = col_character(), weight = col_double())
)

all_dataset_ids <- fs::dir_ls(groundtruths_folder) %>% fs::path_file() %>% fs::path_ext_remove()

# load in the scores
scores <- map_df(all_dataset_ids, function(dataset_id) {
  scores_path <- fs::path(output_folder, dataset_id, "scores.json")

  # load scores if available, otherwise return 0
  if (fs::file_exists(scores_path)) {
    scores <- jsonlite::read_json(scores_path)[[1]]
    scores$dataset_id <- dataset_id
    scores
  } else {
    list(dataset_id = dataset_id)
  }
}) %>%
  gather(-dataset_id, key = "metric", value = "score")

cat("\U2713 Reading scores \n")
cat("> Normalizing and aggregating scores \n")

# normalize the scores by the difficulty
scores <- scores %>%
  left_join(difficulties, c("dataset_id", "metric")) %>%
  mutate(normalized = pnorm((score - mean)/sd)) %>%
  mutate(normalized = ifelse(is.na(normalized), 0, normalized))

# aggregate across metrics
geometric_mean <- function(x) {
  prod(x)**(1/length(x))
}

dataset_scores <- scores %>%
  group_by(dataset_id) %>%
  summarise(metric = "geometric_mean", score = geometric_mean(normalized))

readr::write_csv(dataset_scores, fs::path(output_folder, "dataset_scores.csv"))

# aggregate across datasets
overall_score <- dataset_scores %>%
  left_join(weights, "dataset_id") %>%
  mutate(weighted_score = score * weight) %>%
  pull(weighted_score) %>%
  sum()

write(overall_score, fs::path(output_folder, "AGGREGATED_SCORE"))

cat("\U2713 Normalizing and aggregating scores \n")
