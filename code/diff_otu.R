## @knitr otu


B_CO = read.biome(paste0(data_use,'CO_bacteria.rds'))
B_FD =read.biome(paste0(data_use,'FD_bacteria.rds'))
B = list(B_FD = B_FD, B_CO = B_CO)

# Fonction pour identifier les lignes différentiellement exprimées
identification_lignes_differentielles <- function(matrice1, matrice2) {
  lignes_differentielles <- c()
  p_values = c()
  estimates = c()
  for (i in 1:nrow(matrice1)) {
    test_result <- t.test(matrice1[i,], matrice2[i,])
    p_values[i] <- test_result$p.value
    estimates[i] = test_result$estimate |> diff()
  }
  return(list(p_values,estimates))
}

#otu_list comprend tout les otus qui ont un impact sur le phénotype (subset et meme nombre donc on peut simplifier par ça) 
otu_list = s$otu_list

results <- identification_lignes_differentielles(B$B_FD, B$B_CO)
p_values = results[[1]]
estimates = results[[2]]


# Calculate variance for each row in the matrices
variances <- apply(B$B_CO, 1, var)+ apply(B$B_FD,1,var)
moyenne <- apply(B$B_FD, 1, mean)


tibble(
  estimate = estimates,
  pval     = p_values, 
  var      = variances
) |> ggplot(aes(x = pval, y = log(var), color = estimate)) +
  geom_point() + 
  scale_color_distiller(type = "div") +
  theme_bw()

# Indices des lignes avec des p-values entre 0.3 et 0.4
indices <- which(p_values >= 0.3 & p_values <= 0.4)

# Affichage des valeurs des lignes correspondantes
for (i in indices) {
  ligne <- otu_list[i]
  valeurs <- B$B_FD[i,]
}

# Boxplot des variances des lignes correspondantes

plot(variances, main = "Répartition des variances entre 0,3 et 0,4", ylab = "Variance", col = "lightblue")





# Plot variance vs. p-values
plot(p_values, variances, xlab = "p-value", ylab = "Variance", main = "Variance vs. p-value", 
     pch = 16, col = "blue")


plot(p_values, moyenne, xlab = "p-value", ylab = "Moyenne", main = "Moyenne vs. p-value", 
     pch = 16, col = "blue")




# Calculate logarithm of variance for each row in the matrices
log_variances <- (log(apply(B$B_CO, 1, var)) + log(apply(B$B_FD, 1, var)))/2

# Plot logarithm of variance vs. p-values
plot(p_values, log_variances, xlab = "p-value", ylab = "Log Variance", 
     main = "Log Variance vs. p-value", pch = 16, col = rgb(0, 0, 1, alpha = 0.05))



# Seuil de variance minimale
seuil_log_variance <- -6

# Identifier les indices des lignes avec des variances supérieures au seuil
indices_filtrés <- which(log_variances >= seuil_log_variance)

# Filtrer les p-values correspondantes aux lignes sélectionnées
p_values_filtrés <- p_values[indices_filtrés]

# Tracer l'histogramme des p-values filtrées
hist(p_values_filtrés, main = "Distribution des p-values (variances filtrées)",
     xlab = "p-value", ylab = "Fréquence")

p_adjust <- p.adjust(p_values_filtrés, method = "BH")
which(p_adjust <= 0.01) 



################################################
#PRINT OTU DIFF
################################################




print(otu_differentielles)
print(paste0("nombre d'otu diff : ",  length(otu_differentielles)))



library(venn)

# Créer le diagramme de Venn
venn_result <- venn(otu_list, otu_differentielles, name

)




# Créer les données sous forme de liste
data <- list(otu_simu = otu_list, otu_diff = otu_differentielles)

# Spécifier les noms des ensembles
names <- c("otu_simu", "otu_diff")

# Créer le diagramme de Venn avec les options spécifiées
venn(data, names = names, showSetLogicLabel = TRUE, simplify = TRUE)
