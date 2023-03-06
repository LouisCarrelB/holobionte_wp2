#!/bin/bash
QSUB="qsub -S /usr/local/public/R/bin/Rscript -q short.q -cwd -V -M louis.carrel-billiard@inrae.fr -m a"
CREATE_JOB="code/create_datasets.R"
ESTIMATE_JOB="code/estimate_parameter.R"
seq 1 100 | xargs -I {} $QSUB -o results/job_cr_{}.out -e results/job_cr_{}.err -N R_job_cr_{} $CREATE_JOB {}
seq 1 100 | xargs -I {} $QSUB -o results/job_es_{}.out -e results/job_es_{}.err -N R_job_es_{} $ESTIMATE_JOB {}