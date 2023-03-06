args <- commandArgs(trailingOnly = TRUE)
simulation_ID <- as.numeric(args[1])

#### Espace des paramètres à explorer ####
params <- tibble::tibble(
  mean = 1:100,
  n    = rep(10000, 100)
)

#### Fonctions de création de jeu de données ####
create_dataset_from_params <- function(mean, n) {
  x <- rnorm(n = n, mean = mean)
}

create_dataset <- function(i) {
  params_i <- params[i, ]
  dataset_i <- create_dataset_from_params(mean = params_i$mean, 
                             n    = params_i$n)
  ## save dataset in a rds file
  readr::write_rds(dataset_i, file = glue::glue("results/dataset_{i}.rds"))
}


#### Usage du script #### 
create_dataset(simulation_ID)
