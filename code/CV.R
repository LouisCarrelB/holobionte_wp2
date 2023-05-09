## @knitr CV
load(paste0(path_RDS,'simubiome.Rdata'))



#--> scale and transpose data
y = scale(s$y)


file.remove(paste0(path_RDS,'simubiome.Rdata'))


G_all = readRDS(paste0(path_RDS,"g_",regime,".RDS"))
B_all = readRDS(paste0(path_RDS,"b_",regime,".RDS"))
A_all = readRDS(paste0(path_RDS,"a_",regime,".RDS"))

df<- list()
df_A =list()


for (CV in c("G","B","A")) {
  cors_gb <- c()
  cors_g <- c()
  cors_b <- c()
  Acors_gb <- c()
  Acors_g <- c()
  Acors_b <- c()
  all <- get(paste0(CV,"_all"))
  for (cluster in 1:10) {
    tst <- all[[cluster]]$tst
    cor_gb <- cor(all[[cluster]]$fm_Ggb$fm$yHat[tst],y[tst])
    cor_g <- cor(all[[cluster]]$fm_Gg$fm$yHat[tst],y[tst])
    cor_b <- cor(all[[cluster]]$fm_Gb$fm$yHat[tst],y[tst])
    Acor_gb <- cor(all[[cluster]]$fm_Ggb$fm$yHat[-tst],y[-tst])
    Acor_g <- cor(all[[cluster]]$fm_Gg$fm$yHat[-tst],y[-tst])
    Acor_b <- cor(all[[cluster]]$fm_Gb$fm$yHat[-tst],y[-tst])
    Acors_gb <- append(Acors_gb, Acor_gb) 
    Acors_g <- append(Acors_g, Acor_g) 
    Acors_b <- append(Acors_b, Acor_b) 
    cors_gb <- append(cors_gb, cor_gb) 
    cors_g <- append(cors_g, cor_g) 
    cors_b <- append(cors_b, cor_b) 
    
  }
  
  df[[CV]] <- data.frame("GB" = cors_gb,"G" = cors_g,"B" = cors_b)
  df_A[[CV]] <- data.frame("GB" = Acors_gb,"G" = Acors_g,"B" = Acors_b)


}

write.csv(df,paste0(path_RDS,"df_corr"))
write.csv(df_A,paste0(path_RDS,"df_corr_a"))

# Melt the data frame into long format
Matrice <- melt(df)
colnames(Matrice) = c("Model","corr","CV")
Matrice_A <- melt(df_A)
colnames(Matrice_A) = c("Model","corr","CV")


saveRDS(Matrice,paste0(path_RDS,"df_corr.RDS"))
saveRDS(Matrice_A,paste0(path_RDS,"df_corr_a.RDS"))


boxplot(df$G, horizontal = TRUE, col = c("darkorange", "deepskyblue", "forestgreen"), 
        main = "Correlation des valeurs prédite par l'apprentissage sur un cluster génétique", 
        xlab = "Correlations")

boxplot(df$B, horizontal = TRUE, col = c("darkorange", "deepskyblue", "forestgreen"), 
        main = "Correlation des valeurs prédite par l'apprentissage sur un cluster microbien", 
        xlab = "Correlations")

boxplot(df$A, horizontal = TRUE, col = c("darkorange", "deepskyblue", "forestgreen"), 
        main = "Correlation des valeurs prédite par l'apprentissage sur un cluster aléatoire", 
        xlab = "Correlations")




ggplot(Matrice) + geom_boxplot(aes(x = corr, y = CV)) + facet_grid(Matrice$Model)

ggplot(Matrice_A) + geom_boxplot(aes(x = corr, y = CV)) + facet_grid(Matrice_A$Model)

