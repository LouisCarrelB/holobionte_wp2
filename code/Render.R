args = commandArgs(trailingOnly=TRUE)



rmarkdown::render('code/Simu_perez.Rmd', output_file = glue::glue("results/{args[1]}/Simu_perez.html"), params = list(scenario = args[1]))
rmarkdown::render('code/Cross_Validation.Rmd', output_file = glue::glue("results/{args[1]}/Cross_Validation.html"), params = list(scenario = args[1]))