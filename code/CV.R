## @knitr CV
load(paste0(WORKING_DIR,'simubiome.Rdata'))



#--> scale and transpose data
X = scale(t(s$X))
B = scale(t(s$B))
y = scale(s$y)




G_all = readRDS(paste0(path_RDS,"g_",regime,".RDS"))
B_all = readRDS(paste0(path_RDS,"b_",regime,".RDS"))
A_all = readRDS(paste0(path_RDS,"a_",regime,".RDS"))

df<- list()


for (CV in c("G","B","A")) {
  cors_gb <- c()
  cors_g <- c()
  cors_b <- c()
  all <- get(paste0(CV,"_all"))
  for (cluster in 1:10) {
    tst <- all[[cluster]]$tst
    cor_gb <- cor(all[[cluster]]$fm_Ggb$fm$yHat[tst],y[tst])
    cor_g <- cor(all[[cluster]]$fm_Gg$fm$yHat[tst],y[tst])
    cor_b <- cor(all[[cluster]]$fm_Gb$fm$yHat[tst],y[tst])
    cors_gb <- append(cors_gb, cor_gb) 
    cors_g <- append(cors_g, cor_g) 
    cors_b <- append(cors_b, cor_b) 
    
  }
  
  df[[CV]] <- data.frame("GB" = cors_gb,"G" = cors_g,"B" = cors_b)

}

boxplot(df$G, horizontal = TRUE, col = c("darkorange", "deepskyblue", "forestgreen"), 
        main = "Correlation des valeurs prédite par l'apprentissage sur un cluster génétique", 
        xlab = "Correlations")

boxplot(df$B, horizontal = TRUE, col = c("darkorange", "deepskyblue", "forestgreen"), 
        main = "Correlation des valeurs prédite par l'apprentissage sur un cluster microbien", 
        xlab = "Correlations")

boxplot(df$A, horizontal = TRUE, col = c("darkorange", "deepskyblue", "forestgreen"), 
        main = "Correlation des valeurs prédite par l'apprentissage sur un cluster aléatoire", 
        xlab = "Correlations")