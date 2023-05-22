#!/bin/bash
QSUB="qsub -S /usr/local/public/R/bin/Rscript -q short.q -cwd -V -M louis.carrel-billiard@inrae.fr -m a"
render_script="code/Render_CV.R"
Simulation_scenario=("microbiome" "join" "recursif")
Modele="code/Modèle.R"

for {fold in 1.10}
do
  for run in {21..25}
  do
    for scenario in "${Simulation_scenario[@]}"
    do
      $QSUB -N R_job_cr_fold_${scenario}_${run}_${fold} $Modele ${scenario} ${run} ${fold}
    done
  done
done


then 

for run in {21..25}
do
  for scenario in "${Simulation_scenario[@]}"
  do
    $QSUB -N R_job_cr_modele_${scenario}_${run} $render_script ${scenario} ${run}
  done
done
