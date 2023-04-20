
#PARAM #########################################################################
regime = "CO" #CO or FD or all 
data_use = data2  # data1 = PEREZ or data2 = VERU
seuil_geno = 30 
seuil_micro = 30
Data_PCA = "simubiome"


if (scenario == "microbiome") {
#--> main parameters for simulation 
h2 = 0
b2 = 0.25
Nqtl_y = 0
Notu_y = 25
Notu_y_g = 25
Nqtl_otu = 0
Nclust = 500  }



if (scenario == "join") {
  #--> main parameters for simulation 
  h2 = 0.25
  b2 = 0.25
  Nqtl_y = 100
  Notu_y = 25
  Notu_y_g = 0
  Nqtl_otu = 0
  Nclust = 500 }


if (scenario == "recursif") {
  #--> main parameters for simulation 
h2 = 0.25
b2 = 0.25
Nqtl_y = 100
Notu_y = 25
Notu_y_g = 25
Nqtl_otu = 10
Nclust = 500
Nmiss = 75 }



#### Debug

.SHOWFLEXBORDERS = FALSE;
.VERBOSE = FALSE;