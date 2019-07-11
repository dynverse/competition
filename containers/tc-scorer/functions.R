process_scores <- function(dataset_id, output_folder) {
  scores_path <- fs::path(output_folder, dataset_id, "scores.json")

  # load scores if available, otherwise return 0
  if (fs::file_exists(scores_path)) {
    scores <- jsonlite::read_json(scores_path)[[1]]
    scores$dataset_id <- dataset_id

    time_path <- fs::path(output_folder, dataset_id, "time.txt")
    if (fs::file_exists(time_path)) {
      scores$time <- as.double(scan(time_path))
    } else {
      scores$time <- Inf
    }
    scores$time <- process_time(time)

    scores
  } else {
    list(dataset_id = dataset_id, time = process_time(Inf))
  }
}

process_time <- function(time, time_min = 1, time_max = 180) {
  if (is.na(time)) {
    score_time <- 0
  } else {
    if (time < time_min) {
      time <- time_min
    } else if (time > time_max) {
      time <- time_max
    }
    score_time <- 1 - (log(time)-log(time_min)) / (log(time_max) - log(time_min))
  }
  score_time
}
