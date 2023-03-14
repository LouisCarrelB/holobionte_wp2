
B_raw = read.table(paste0(path_simu,'bacteria_1.txt.gz'), header=T)
X_raw = read.table(paste0(path_simu,'gen.txt.gz'),  header=T)
pheno <- fread(paste0(path_pheno,"donnees_phenotypes.txt"))


## filtre pour tout les individus ######################                 
noms_lignes_communs <- intersect(rownames(X_raw), rownames(B_raw))


X_communs <- X_raw[noms_lignes_communs, ] 
B_communs <- B_raw[noms_lignes_communs, ]

write.table(B_communs, file = gzfile(paste0(path_output,"all_bacteria.txt.gz")), sep = "\t", 
            col.names = TRUE, row.names = TRUE, quote = TRUE, 
)

write.table(X_communs, file = gzfile(paste0(path_output,"all_gen.txt.gz")), sep = "\t", 
            col.names = TRUE, row.names = TRUE, quote = TRUE, 
)

## QC_all ####################################

X_communs = rownames_to_column(X_communs, var = "numero_animal")
B_communs = rownames_to_column(B_communs, var = "numero_animal")
X_communs = X_communs %>% mutate(numero_animal = as.integer(numero_animal))
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

noms_lignes_communs_CO <- intersect(rownames(X_father_CO), rownames(B_communs))

X_communs_CO <- X_raw[noms_lignes_communs_CO, ]
B_communs_CO <- B_raw[noms_lignes_communs_CO, ]

write.table(B_communs_CO, file = gzfile(paste0(path_output,"CO_bacteria.txt.gz")), sep = "\t", 
            col.names = TRUE, row.names = TRUE, quote = TRUE, 
)

write.table(X_communs_CO, file = gzfile(paste0(path_output,"CO_gen.txt.gz")), sep = "\t", 
            col.names = TRUE, row.names = TRUE, quote = TRUE, 
)

## FD #############################################

X_father_FD = subset(X_father , regime == "FD")
X_father_FD <- rownames_to_column(X_father_FD, var = numero_animal)

noms_lignes_communs_FD <- intersect(rownames(X_father_FD), rownames(B_communs))

X_communs_FD <- X_raw[noms_lignes_communs_FD, ]
B_communs_FD <- B_raw[noms_lignes_communs_FD, ]



write.table(B_communs_FD, file = gzfile(paste0(path_output,"FD_bacteria.txt.gz")), sep = "\t", 
            col.names = TRUE, row.names = FALSE, quote = TRUE, 
)

write.table(X_communs_FD, file = gzfile(paste0(path_output,"FD_gen.txt.gz")), sep = "\t", 
            col.names = TRUE, row.names = FALSE, quote = TRUE, 
)
