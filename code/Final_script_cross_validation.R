library(gridExtra)



df_join = readRDS("../data/RDS/join/df_corr.RDS")
df_recursif = readRDS("../data/RDS/recursif/df_corr.RDS")
df_microbiome = readRDS("../data/RDS/microbiome/df_corr.RDS")


# Définir une palette de couleurs pour les facettes
  col_pal <- c("pink", "red", "orange")

# Créer les plots pour chaque matrice
plot1 <- ggplot(df_join) + 
  geom_boxplot(aes(x = corr, y = CV, fill = Model)) + 
  facet_grid(df_join$Model) +
  ggtitle("join") +
  scale_fill_manual(values = col_pal) + 
  geom_segment(aes(x = 0, y = -Inf, xend = 0, yend = Inf), linetype = "dashed")

plot2 <- ggplot(df_recursif) + 
  geom_boxplot(aes(x = corr, y = CV, fill = Model)) + 
  facet_grid(df_recursif$Model) +
  ggtitle("recursive") +
  scale_fill_manual(values = col_pal) +
  geom_segment(aes(x = 0, y = -Inf, xend = 0, yend = Inf), linetype = "dashed")

plot3 <- ggplot(df_microbiome) + 
  geom_boxplot(aes(x = corr, y = CV, fill = Model)) + 
  facet_grid(df_microbiome$Model) +
  ggtitle("microbiome") +
  scale_fill_manual(values = col_pal)+
  geom_segment(aes(x = 0, y = -Inf, xend = 0, yend = Inf), linetype = "dashed")

# Ajouter des lignes verticales à x = h2 et x = b2
plot1 <- plot1 + geom_segment(aes(x = h2, y = -Inf, xend = h2, yend = Inf), color = "blue") +
  geom_segment(aes(x = b2, y = -Inf, xend = b2, yend = Inf), color = "green")
plot2 <- plot2 + geom_segment(aes(x = h2, y = -Inf, xend = h2, yend = Inf), color = "blue") +
  geom_segment(aes(x = b2, y = -Inf, xend = b2, yend = Inf), color = "green")
plot3 <- plot3 + geom_segment(aes(x = h2, y = -Inf, xend = h2, yend = Inf), color = "blue") +
  geom_segment(aes(x = b2, y = -Inf, xend = b2, yend = Inf), color = "green")


# Aligner les trois plots
xlims <- range(df_join$corr, df_recursif$corr, df_microbiome$corr)
plot1 <- plot1 + xlim(xlims)
plot2 <- plot2 + xlim(xlims)
plot3 <- plot3 + xlim(xlims)

grid.arrange(plot1, plot2, plot3, ncol = 3)
