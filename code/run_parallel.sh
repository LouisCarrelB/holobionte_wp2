#!/bin/bash
QSUB="qsub -S /usr/local/public/R/bin/Rscript -q short.q -cwd -V -M louis.carrel-billiard@inrae.fr -m a"
render_script="code/Render.R"
Simulation_scenario=("microbiome" "join" "recursif")

for scenario in "${Simulation_scenario[@]}"
do
  # $QSUB -o results/${scenario}/job_cr.out -e results/${scenario}/job_cr.err -N R_job_cr_${scenario} $render_script ${scenario}
  $QSUB -N R_job_cr_${scenario} $render_script ${scenario}
done


