path_pheno = "./data/Vanille_Deru/donnees_pheno/"

path_simu = "./data/Vanille_Deru/simulation/"
path_output = "./data/Vanille_Deru/simulation/"
B_raw = read.table(paste0(path_simu,'bacteria_1.txt.gz'), header=T)
X_raw = read.table(paste0(path_simu,'gen.txt.gz'),  header=T)
pheno <- fread(paste0(path_pheno,"donnees_phenotypes.txt"))
                      
noms_lignes_communs <- intersect(rownames(X_raw), rownames(B_raw))

X_communs <- X_raw[noms_lignes_communs, ]
B_communs <- B_raw[noms_lignes_communs, ]



write.table(B_communs, file = gzfile(paste0(path_output,"bacteria.txt.gz")), sep = "\t", 
            col.names = TRUE, row.names = TRUE, quote = TRUE, 
)

write.table(X_communs, file = gzfile(paste0(path_output,"gen.txt.gz")), sep = "\t", 
            col.names = TRUE, row.names = TRUE, quote = TRUE, 
)


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
# Création du diagramme de Venn

ggVennDiagram( X_father_count, label_alpha = 0,   
               category.names = c("FC","CO")
               ) +
                 ggplot2::scale_fill_gradient(low="blue",high = "yellow")


upset(
  X_father_count,
  sets = c("FD", "CO"),
  sets.bar.color = c("#377EB8")
  
)




