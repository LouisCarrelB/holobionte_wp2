compte_0_1 <- function(matrice) {
  nbre_0 <- sum(matrice == 0)
  nbre_1 <- sum(matrice == 1)
  return(c(nbre_0, nbre_1))
}


library(ggplot2)

# Créer le graphique avec ggplot2
graphique <- ggplot(data.frame(x = table(B_raw)), aes(table(B_raw))) +
  geom_histogram(bins = 100, fill = "blue", color = "black") +
  scale_x_log10() +
  labs(title = "Histogramme en échelle log", x = "Valeurs logarithmiques", y = "Fréquence")

# Afficher le graphique
print(graphique)