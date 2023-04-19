
## @knitr Cluster_B


if (regime == "all") {var = var_exp_b} else {var = var_exp_regime_b} 

# Initialisation de la somme et du numéro de PC
somme <- 0
num_pc <- 0

# Boucle pour trouver le numéro de PC correspondant au seuil
for (i in 1:length(var)) {
  somme <- somme + var[i]
  if (somme >= seuil_micro) {
    num_pc <- i
    break
  }
}

# Affichage du résultat
if (num_pc > 0) {
  print(paste("PC", num_pc, "pour une variance de", somme, "%"))
} else {
  print("Aucune PC ne correspond au seuil spécifié pour la variance explicative des composantes principales")
}


if (regime == "all") {PCA = my_pca_b$x} else {
  PCA = get(paste0("my_pca_",regime,"_b"))$x}


my_pca_PCs <- PCA[,1:num_pc]



pca_kmeans = kmeans(my_pca_PCs,10, nstart = 1)
saveRDS(pca_kmeans,(paste0(path_RDS,"pca_kmeans_b.RDS")))

#Create data frame with PC1 and PC2 columns
if (regime != "all") {my_pca_b = get(paste0("my_pca_",regime,"_b"))}
df <- data.frame(PC1 = my_pca_b$x[,1], PC2 = my_pca_b$x[,2], 
                 cluster =  factor(pca_kmeans$cluster))

## @knitr quantitative_B


kable(count(df, cluster))



