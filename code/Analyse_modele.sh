#!/bin/bash
QSUB="qsub -S /usr/local/public/R/bin/Rscript -q short.q -cwd -V -M louis.carrel-billiard@inrae.fr -m a"
render_script="code/Render_CV.R"
Simulation_scenario=( "join" "recursif" "microbiome")

for run in {2..6}
do
  for scenario in "${Simulation_scenario[@]}"
  do
    $QSUB -N R_job_cr_${scenario}_${run} $render_script ${scenario} ${run}
  done
done

