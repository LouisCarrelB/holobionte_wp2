

# read bacteria
if (data_use == data1) {B = read.biome(paste0(data_use,'bacteria.txt.gz'))}
if (data_use == data2) {B = read.biome(paste0(data_use,regime,'_bacteria.txt.gz'))}

# read archaea (not used)
if (data_use == data1) {A = read.biome(paste0(data_use,'archea.txt.gz'))}

# read genotypes

if (data_use == data1) {X = read.gen(paste0(data_use,'gen.txt.gz'))}
if (data_use == data2) {X = read.gen(paste0(data_use,regime,'_gen.txt.gz'))}

# N SNPs
Nsnp = nrow(X)
# N individuals
Nind = ncol(X)
# N OTUs
Notu = nrow(B)
try (if (Nind != ncol(B)) stop('Nind in B and X does not match'))


# Clusters st minimum within cluster cor is > 3rd quantile average rho
Cl=hclust(dist(B),method="ward.D2")
saveRDS(Cl, file = paste0(data_use,"Cluster"))



#--> main parameters
h2 = 0.25
b2 = 0.25
Nqtl_y = 100
Notu_y = 25
Notu_y_g = 25
Nqtl_otu = 10
Nclust = 500
Nmiss = 75

Bclust=cutree(Cl,Nclust)
#--> simulate data
s = SimuBiome(X, B, Bclust=Bclust, h2=h2, b2=b2, Nqtl_y=Nqtl_y, Notu_y=Notu_y, Notu_y_g=Notu_y_g)
print(names(s))
# simulated phenotype
y = s$y
# returns reordered B, always in log scale,
# Note: B is shuffled wrt to genotypes in every call to SimuBiome irrespective of the model
B = s$B

#--> plots
par(mfrow=c(2,2))
hist(s$gq, main='Indiv Genetic values')
hist(s$gb, main='Indiv Genetic values')
hist(abs(s$b_qtl), main='Genetic coefficients (abs)')
print(c('Nqtl ',length(s$b_qtl)))
hist(abs(s$b_otu), main='Microbiome coefficients (abs)')
print(c('Notu causative ',length(s$b_otu)))

#--> save simubiome data
save(s,file='simubiome.Rdata')

#--> scale and transpose data
X = scale(t(X))
B = scale(t(B))
y = scale(y)

#--> prediction
tst = sample(seq(length(y)),size=Nmiss)
yNA = y
yNA[tst] = NA