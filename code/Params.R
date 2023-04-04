
#PARAM #########################################################################
a = 'otu' #geno or otu for the pca analysis 
regime = "CO" #CO or FD or all 
data_use = data2  # data1 = PEREZ or data2 = VERU
seuil = 30 
CV = "Géno"

#--> main parameters for simulation 
h2 = 0.25
b2 = 0.25
Nqtl_y = 100
Notu_y = 25
Notu_y_g = 25
Nqtl_otu = 10
Nclust = 500
Nmiss = 75

#### Debug

.SHOWFLEXBORDERS = FALSE;
.VERBOSE = FALSE;