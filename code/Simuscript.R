# folder containing snp and otu data
data1 = "C:/Users/lcarrel/Nextcloud/pepr-holobionts-wp2/data/Pérez/"
data2= "C:/Users/lcarrel/Nextcloud/pepr-holobionts-wp2/data/Vanille_Deru/simulation/"

data_use = data2  # data1 or data2

# read bacteria
B = read.biome(paste0(data_use,'bacteria.txt.gz'))

# read archaea (not used)
if (data_use == data1) {A = read.biome(paste0(data_use,'archea.txt.gz'))}
# read genotypes
X = read.gen(paste0(data_use,'gen.txt.gz'))
X_raw = read.table(paste0(data_use,'gen.txt.gz'),  header=T)
# N SNPs
Nsnp = nrow(X)
# N individuals
Nind = ncol(X)
# N OTUs
Notu = nrow(B)
try (if (Nind != ncol(B)) stop('Nind in B and X does not match'))

#--> main parameters
h2 = 0.25
b2 = 0.25
Nqtl_y = 100
Notu_y = 25
Notu_y_g = 25
Nqtl_otu = 10
Nclust = 500
Nmiss = 75

# Clusters st minimum within cluster cor is > 3rd quantile average rho
Cl=hclust(dist(B),method="ward.D2")
Bclust=cutree(Cl,Nclust)


#--> simulate data
s = SimuBiome(X, B=B, Bclust=Bclust, h2=h2, b2=b2, Nqtl_y=Nqtl_y, Notu_y=Notu_y, Notu_y_g=Notu_y_g)
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