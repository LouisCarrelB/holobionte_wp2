#LIBRARY #######################################################################

library(snpStats)
library(data.table)
library(ggplot2)
library(tidyverse)
library(devtools)
library(FactoMineR)
library(utils)
library(data.table)
library(BGLR)

#PATH ##########################################################################

path_pheno = "../data/Vanille_Deru/donnees_pheno/"
path_OTU = "../data/Vanille_Deru/donnees_microbiote/"
path_output = "../data/Vanille_Deru/simulation/" 
path_simu = path_output
# folder containing snp and otu data
data1 = "./data/Pérez/" #PEREZ
data2 = "./data/Vanille_Deru/simulation/" # VANILLE DERU

#PARAM #########################################################################
a = 'otu' #geno or otu for the pca analysis 
regime = "CO" #CO or FD or all 
data_use = data1  # data1 or data2