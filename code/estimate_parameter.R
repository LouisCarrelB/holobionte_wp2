#### Lire les paramètres en entrée de ma fonction ####
args <- commandArgs(trailingOnly = TRUE)
simulation_ID <- as.numeric(args[1])

#### Fonction d'aide pour lire un jeu de données et en estimer un paramètre ####
estimate_parameter <- function(i) {
  data <- readr::read_rds(glue::glue("results/dataset_{i}.rds"))
  parameter <- mean(data)
  readr::write_rds(parameter, glue::glue("results/parameter_{i}.rds"))
}

#### Usage du script #### 
estimate_parameter(simulation_ID)