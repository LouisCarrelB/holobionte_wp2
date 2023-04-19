#!/bin/bash
QSUB="qsub -S /usr/local/public/R/bin/Rscript -q short.q -cwd -V -M louis.carrel-billiard@inrae.fr -m a"
SIMULATIONQC="code/Simu_perez.Rmd"
Cross_Validation="code/Cross_validation.Rmd"
Simulation_senario=("microbiome", "join", "recursif")

for senario in "${Simulation_senario[@]}"
do
  xargs -I {} $QSUB -o results/${senario}/job_cr_{}.out -e results/job_cr_{}.err -N R_job_cr_{} $SIMULATIONQC {}
  xargs -I {} $QSUB -o results/${senario}/job_es_{}.out -e results/job_es_{}.err -N R_job_es_{} $Cross_Validation {}
done