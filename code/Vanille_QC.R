library(snpStats)
library(data.table)
library(ggplot2)
library(tidyverse)
library(devtools)
library(FactoMineR)
library(missMDA)


path_geno = "C:/Users/lcarrel/Nextcloud/pepr-holobionts-wp2/data/Vanille_Deru/donnees_geno/"
path_pheno = "C:/Users/lcarrel/Nextcloud/pepr-holobionts-wp2/data/Vanille_Deru/donnees_pheno/"
path_OTU = "C:/Users/lcarrel/Nextcloud/pepr-holobionts-wp2/data/Vanille_Deru/donnees_microbiote/"
path_output = "C:/Users/lcarrel/Nextcloud/pepr-holobionts-wp2/data/Vanille_Deru/simulation/"
a = 'otu' #geno or otu for the pca analysis 
  

pheno <- fread(paste0(path_pheno,"donnees_phenotypes.txt"))
pop1 <- data.frame(pheno$regime)
rownames(pop1) = pheno$numero_animal

############################################################################################
if (a == 'geno') {
sample <- read.pedfile(paste0(path_geno,"genoMicroFeed.ped"), snps= paste0(path_geno,"genoMicroFeed.map"))
geno1 <- sample$genotypes

# trouver les noms de lignes communs


noms_lignes_communs <- sort(intersect(rownames(geno1), rownames(pop1)))

# extraire les lignes correspondantes de la data table
geno <- geno1[rownames(geno1) %in% noms_lignes_communs]
pop <- pop1[noms_lignes_communs,]

gen = as.matrix(geno@.Data)

gen2<- gen[, colSums(is.na(gen)) == 0]


xxmat <- xxt(geno, correct.for.missing=FALSE)

evv <- eigen(xxmat, symmetric=TRUE)
pcs <- evv$vectors[,1:5]
#evals <- evv$values[1:5]

# Combinaison des données de pcs et de pop dans un seul data frame
pcs_pop <- data.frame(PC1 = pcs[,1], PC2 = pcs[,2], pop)

# Tracé du graphique
ggplot(pcs_pop, aes(x = PC1, y = PC2, color = pop)) + 
  geom_point() + 
  labs(x = "PC1", y = "PC2", color = "Regime")


write.table(gen2, file = gzfile(paste0(path_output,"gen.txt.gz")), sep = "\t", 
            col.names = TRUE, row.names = TRUE, quote = TRUE, 
)


}

##################################################################################################
if (a == 'otu') {
# Open OTU data and make 'numero_individu' as character  
micro1 = fread(paste0(path_OTU,"donnees_microbiote_rarefie.txt")) 
micro2 <- micro1 %>% mutate(numero_individu = as.character(numero_individu))

#Permet de crée deux df pop et micro qui ont comme noms de lignes les mêmes individus
pop2 <- rownames_to_column(pop1, var = "numero_individu")
micro3 = inner_join(micro2,pop2,by= 'numero_individu')
micro4 <- micro3 %>% mutate(numero_individu = as.numeric(numero_individu))

pop3 <- select(micro4,c('numero_individu','pheno.regime'))
pop <-column_to_rownames(pop3, var = "numero_individu")

micro5 <-column_to_rownames(micro4, var = "numero_individu")
micro <- select(micro5, -'pheno.regime')
rm_index = which (apply(micro,2,var) == 0 ) 
micro = micro[,-rm_index]


#Calcul l'ACP
acp <- PCA(log(micro+1), graph = FALSE)
coord <- data.frame(acp$ind$coord[,1:2])
coord$individu <- rownames(coord)
colnames(coord)[1:2] <- c("PC1", "PC2")

ggplot(coord, aes(x = PC1, y = PC2)) +
  geom_point() +
  labs(title = "Graphique ACP en 2 dimensions", x = "PC1", y = "PC2")

# Combinaison des données de pcs et de pop dans un seul data frame
pcs_pop <- data.frame(PC1 = coord$PC1, PC2 = coord$PC2 , pop=pop$pheno.regime)

# Tracé du graphique
ggplot(pcs_pop, aes(x = PC1, y = PC2, color = pop)) + 
  geom_point() + 
  labs(x = "PC1", y = "PC2", color = "Regime")

write.table(micro, file = gzfile(paste0(path_output,"bacteria_1.txt.gz")), sep = "\t", 
            col.names = TRUE, row.names = TRUE, quote = TRUE, 
)

}




