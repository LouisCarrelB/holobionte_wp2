#!/bin/bash
QSUB="qsub -S /usr/local/public/R/bin/Rscript -q short.q -cwd -V -M louis.carrel-billiard@inrae.fr -m a"
Simulation_scenario=("microbiome" "join" "recursif")
Modele="/home/lcarrel/work/holobionte_wp2/code/Modèles.R"

for fold in {1..10}
do
  for run in {2..6}
  do
    for scenario in "${Simulation_scenario[@]}"
    do
      mkdir -p /home/lcarrel/work/holobionte_wp2/data/RDS/${scenario}/${run}/${fold}
      cd /home/lcarrel/work/holobionte_wp2/data/RDS/${scenario}/${run}/${fold}/
      $QSUB -N R_job_cr_fold_${scenario}_${run}_${fold} ${Modele} ${scenario} ${run} ${fold}
    done
  done
done


