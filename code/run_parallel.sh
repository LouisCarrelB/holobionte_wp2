#!/bin/bash
QSUB="qsub -S /usr/local/public/R/bin/Rscript -q short.q -cwd -V -M louis.carrel-billiard@inrae.fr -m a"
render_script="code/Render.R"
Simulation_scenario=("microbiome" "join" "recursif")

for run in {4..6}
do
  for scenario in "${Simulation_scenario[@]}"
  do
    $QSUB -N R_job_cr_${scenario}_${run} $render_script ${scenario} ${run}
  done
done

