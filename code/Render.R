args = commandArgs(trailingOnly=TRUE)

result_dir <- paste0("~/work/holobionte_wp2/results/", args[1], "/", args[2], "/")
data_dir <- paste0("~/work/holobionte_wp2/data/RDS/", args[1], "/", args[2], "/")

if (!file.exists(result_dir)) {
  dir.create(result_dir)
}

if (!file.exists(data_dir)) {
  dir.create(data_dir)
}

output_file_simu <- glue::glue("~/work/holobionte_wp2/results/{args[1]}/{args[2]}/Simu_perez.html")
if (!file.exists(output_file_simu)) {
  rmarkdown::render('code/Simu_perez.Rmd', output_file = output_file_simu, params = list(scenario = args[1], run = args[2]))
}

output_file_cross <- glue::glue("~/work/holobionte_wp2/results/{args[1]}/{args[2]}/Cross_Validation.html")
if (!file.exists(output_file_cross)) {
  rmarkdown::render('code/Cross_Validation.Rmd', output_file = output_file_cross, params = list(scenario = args[1], run = args[2]))
}
