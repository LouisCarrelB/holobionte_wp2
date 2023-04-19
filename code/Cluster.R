
## @knitr Cluster_X


if (regime == "all") {var = var_exp} else {var = var_exp_regime} 

# Initialisation de la somme et du numéro de PC
somme <- 0
num_pc <- 0

# Boucle pour trouver le numéro de PC correspondant au seuil
for (i in 1:length(var)) {
  somme <- somme + var[i]
  if (somme >= seuil_geno) {
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


if (regime == "all") {PCA = my_pca$x} else {
  PCA = get(paste0("my_pca_",regime))$x}


 my_pca_PCs <- PCA[,1:num_pc]



 pca_kmeans = kmeans(my_pca_PCs,10, nstart = 1)
 saveRDS(pca_kmeans,(paste0(path_RDS,"pca_kmeans.RDS")))

 #Create data frame with PC1 and PC2 columns
 if (regime != "all") {X = get(paste0("X_",regime))
                       my_pca = get(paste0("my_pca_",regime))}
 df <- data.frame(PC1 = my_pca$x[,1], PC2 = my_pca$x[,2], 
                  cluster =  factor(pca_kmeans$cluster), pere =X$pere, mere = X$mere)

 # Create scatterplot with color-coded clusters
 ggplot(df, aes(x = PC1, y = PC2, color = cluster)) +
   geom_point() +
   scale_color_discrete(name = "Cluster") +
   ggtitle("PC1 par rapport à PC2 avec les clusters")


 # Create complet scatterplot
 ggplot(df, aes(x = PC1, y = PC2, color = cluster)) +
   geom_point() +
   scale_color_discrete(name = "Cluster") +
   geom_point() + geom_text(aes(label = pere), nudge_y = 0.1) +
   geom_path(aes(x = PC1, y = PC2, group = mere), linetype = "solid")+
   xlab("PC1") +
   ylab("PC2") +
   ggtitle(paste("PCA Plot regime",regime))



## @knitr quantitative_X
 
 df %>% group_by(pere, mere) %>% mutate(dyad = cur_group_id()) %>%
   group_by(dyad) %>% summarize(clusters = paste(cluster, collapse = "-"), dyad_size = n(),
                                n_clusters = length(unique(cluster))) %>% arrange(desc(n_clusters)) -> x
 
 
 kable(count(x, n_clusters))
kable(x[1:20,])
 
 kable(x %>% filter(dyad_size > 1) %>% count(dyad_size, n_clusters) %>% arrange(desc(n_clusters)))
 
 
 
 kable(count(df, cluster))
 
 

 
 