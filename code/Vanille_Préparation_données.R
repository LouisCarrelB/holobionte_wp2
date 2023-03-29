#Préparationd des données de Vanille Deru
## @knitr prep_data_V
  

pheno <- fread(paste0(path_pheno,"donnees_phenotypes.txt"))
pop1 <- data.frame(pheno$regime)
rownames(pop1) = pheno$numero_animal

############################################################################################
if (a == 'geno') {


  # Open OTU data and make 'numero_individu' as character  
  
  geno_raw  = read.table(paste0(path_geno,"try3.raw"), header = F)
  colnames(geno_raw) <- geno_raw[1,]
  geno_raw <- geno_raw[-1,]
  geno_raw <- geno_raw[,-c(1,3,4,5,6)]
  
  #Permet de crée deux df pop et micro qui ont comme noms de lignes les mêmes individus
  pop2 <- rownames_to_column(pop1, var = "IID")
  geno_raw2 = inner_join(geno_raw,pop2,by= 'IID')
 
  
  pop3 <- select(geno_raw2,c('IID','pheno.regime'))
  pop <-column_to_rownames(pop3, var = "IID")
  
  geno <-column_to_rownames(geno_raw2, var = "IID")
  gen <- select(geno, -'pheno.regime')
 


###########################################################################################################################################

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
i = ggplot(pcs_pop, aes(x = PC1, y = PC2, color = pop)) + 
  geom_point() + 
  labs(x = "PC1", y = "PC2", color = "Regime")

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

#################




write.table(gen, file = gzfile(paste0(path_output,"gen.txt.gz")), sep = "\t", 
            col.names = TRUE, row.names = TRUE, quote = TRUE, 
            
)



write.table(micro, file = gzfile(paste0(path_output,"bacteria_1.txt.gz")), sep = "\t", 
            col.names = TRUE, row.names = TRUE, quote = TRUE, 
)

}


###############################################################################
#Vanille 

###############################################################################

B_raw = read.table(paste0(path_simu,'bacteria_1.txt.gz'), header=T)
X_raw = read.table(paste0(path_simu,'gen.txt.gz'),  header=T)
pheno <- fread(paste0(path_pheno,"donnees_phenotypes.txt"))


## filtre pour tout les individus ######################                 
noms_lignes_communs <- intersect(rownames(X_raw), rownames(B_raw))


X_communs <- X_raw[noms_lignes_communs, ] 
B_communs <- B_raw[noms_lignes_communs, ]


## QC_all ####################################

X_communs = rownames_to_column(X_communs, var = "numero_animal")
B_communs = rownames_to_column(B_communs, var = "numero_animal")
X_communs = X_communs %>% mutate(numero_animal = as.integer(numero_animal))
B_communs = B_communs %>% mutate(numero_animal = as.integer(numero_animal))
X_father = inner_join(pheno,X_communs,"numero_animal")


# Création d'un sous-ensemble du dataframe avec seulement les variables intéressantes
X_father_subset <- X_father %>% select(numero_pere, regime)


# Comptage des individus ayant le même numéro de père et un régime différent
X_father_count <- X_father_subset %>% 
  group_by(numero_pere) %>% 
  summarize(FD = sum(regime == "FD"), CO = sum(regime == "CO")) %>% 
  filter(FD > 0 & CO > 0)

X_father_count = as.data.frame(X_father_count)



## CO #############################################


X_father_CO = subset(X_father , regime == "CO")

noms_lignes_communs_CO <- intersect(X_father_CO$numero_animal, B_communs$numero_animal)

X_communs_CO <- X_raw[as.character(noms_lignes_communs_CO), ]
B_communs_CO <- B_raw[as.character(noms_lignes_communs_CO), ]



## FD #############################################

X_father_FD = subset(X_father , regime == "FD")

noms_lignes_communs_FD <- intersect(X_father_FD$numero_animal, B_communs$numero_animal)


X_communs_FD <- X_raw[as.character(noms_lignes_communs_FD), ]
B_communs_FD <- B_raw[as.character(noms_lignes_communs_FD), ]








#######################################################

saveRDS(B_communs,paste0(path_output,"all_bacteria")
)

saveRDS(X_communs,paste0(path_output,"all_gen.rds")
)


saveRDS(B_communs_CO,paste0(path_output,"CO_bacteria.rds")
)

saveRDS(X_communs_CO,paste0(path_output,"CO_gen.rds")
)


saveRDS(B_communs_FD,paste0(path_output,"FD_bacteria.rds")
)

saveRDS(X_communs_FD, paste0(path_output,"FD_gen.rds")
)

### DATA POUR PCA (Ancien format)


write.table(B_communs, file = gzfile(paste0(path_output,"all_bacteria.txt.gz")), sep = "\t", 
            col.names = TRUE, row.names = TRUE, quote = TRUE, 
)

write.table(X_communs, file = gzfile(paste0(path_output,"all_gen.txt.gz")), sep = "\t", 
            col.names = TRUE, row.names = TRUE, quote = TRUE, 
)


write.table(B_communs_CO, file = gzfile(paste0(path_output,"CO_bacteria.txt.gz")), sep = "\t", 
            col.names = TRUE, row.names = TRUE, quote = TRUE, 
)

write.table(X_communs_CO, file = gzfile(paste0(path_output,"CO_gen.txt.gz")), sep = "\t", 
            col.names = TRUE, row.names = TRUE, quote = TRUE, 
)


write.table(B_communs_FD, file = gzfile(paste0(path_output,"FD_bacteria.txt.gz")), sep = "\t", 
            col.names = TRUE, row.names = TRUE, quote = TRUE, 
)

write.table(X_communs_FD, file = gzfile(paste0(path_output,"FD_gen.txt.gz")), sep = "\t", 
            col.names = TRUE, row.names = TRUE, quote = TRUE, 
)
