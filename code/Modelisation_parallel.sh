#!/bin/bash
QSUB="qsub -S /usr/local/public/R/bin/Rscript -q short.q -cwd -V -M louis.carrel-billiard@inrae.fr -m a"
Simulation_scenario=("microbiome" "join" "recursif")
Modele="/home/lcarrel/work/holobionte_wp2/code/Modèles.R"

for fold in {1..10}
do
  for run in {4..5}
  do
    for scenario in "${Simulation_scenario[@]}"
    do
      cd /home/lcarrel/work/holobionte_wp2/data/RDS/${scenario}/${run}/
      $QSUB -N R_job_cr_fold_${scenario}_${run}_${fold} ${Modele} ${scenario} ${run} ${fold}
    done
  done
done



