## @knitr simu


# read bacteria
if (data_use == data1) {B = read.biome(paste0(data_use,'bacteria.txt.gz'))}
if (data_use == data2) {B = read.biome(paste0(data_use,regime,'_bacteria.rds'))
if (regime == "all") {B_CO = read.biome(paste0(data_use,'CO_bacteria.rds'))
                    B_FD =read.biome(paste0(data_use,'FD_bacteria.rds'))}}

# read archaea (not used)
if (data_use == data1) {A = read.biome(paste0(data_use,'archea.txt.gz'))}

# read genotypes

if (data_use == data1) {X = read.gen(paste0(data_use,'gen.txt.gz'))}
if (data_use == data2) {X = read.gen(paste0(data_use,regime,'_gen.rds'))
if (regime == "all") {X_CO = read.gen(paste0(data_use,'CO_gen.rds'))
X_FD =read.gen(paste0(data_use,'FD_gen.rds'))}}

# N SNPs
Nsnp = nrow(X)
# N individuals
Nind = ncol(X)
# N OTUs
Notu = nrow(B)
try (if (Nind != ncol(B)) stop('Nind in B and X does not match'))


# Clusters st minimum within cluster cor is > 3rd quantile average rho


if (file.exists(paste0(data_use,"Cluster/",regime,"Cluster")) == FALSE){
  Cl=hclust(dist(B),method="ward.D2")
  saveRDS(Cl, file = paste0(data_use,"Cluster/",regime,"Cluster"))
  
} else {
  Cl = readRDS(paste0(data_use,"Cluster/",regime,"Cluster")) 
  }


Bclust=cutree(Cl,Nclust)
if (regime == "all") {
# # On met lors du cas "all" les deux objets cluster et B dans des listes afin de pouvoir y avoir accès facilement 

B = list(B_FD = B_FD, B_CO = B_CO)
X = list(X_FD = X_FD, X_CO = X_CO)
}

#--> simulate data
s = SimuBiome(X, B, Bclust=Bclust, h2=h2, b2=b2, Nqtl_y=Nqtl_y, Notu_y=Notu_y, Notu_y_g=Notu_y_g)

# simulated phenotype
y = s$y

# returns reordered B, always in log scale,
# Note: B is shuffled wrt to genotypes in every call to SimuBiome irrespective of the model
B = s$B

#--> plots
par(mfrow=c(2,2))
hist(s$gq, main='Indiv Genetic values')
hist(s$gb, main='Indiv Genetic values')
if (Nqtl_y > 0) {hist(abs(s$b_qtl), main='Genetic coefficients (abs)')
print(c('Nqtl ',length(s$b_qtl)))}
if (Notu_y > 0) {hist(abs(s$b_otu), main='Microbiome coefficients (abs)')
print(c('Notu causative ',length(s$b_otu)))}

#--> save simubiome data
save(s,file=paste0(path_RDS,'simubiome.Rdata'))





