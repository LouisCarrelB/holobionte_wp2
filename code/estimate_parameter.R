estimate_parameter <- function(i) {
  data <- readr::read_rds(glue:glue("results/dataset_{i}.rds"))
  parameter <- mean(data)
  readr::write_rds(parameter, "results/parameter_{i}.rds")
}