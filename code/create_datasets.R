library(tidyverse)

params <- tibble(
  mean = 1:100,
  n    = rep(10000, 100)
)

create_dataset_from_params <- function(mean, n) {
  x <- rnorm(n = n, mean = mean)
}

create_dataset <- function(i) {
  params_i <- params[i, ]
  dataset_i <- create_dataset_from_params(mean = params_i$mean, 
                             n    = params_i$n)
  ## save dataset in a rds file
  write_rds(dataset_i, file = glue::glue("results/dataset_{i}.rds"))
}
