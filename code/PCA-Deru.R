## @knitr PCA_Deru



X_FD = fread(paste0(path_output,"FD_gen.txt.gz"))
X_CO = fread(paste0(path_output,"CO_gen.txt.gz"))

pheno <- fread(paste0(path_pheno,"donnees_phenotypes.txt"))
pop1 <- data.frame("V1" = pheno$numero_animal, "pere" = pheno$numero_pere, "mere" = pheno$numero_mere)


X_FD <- X_FD %>% mutate(V1 = as.integer(V1))
X_FD = inner_join(pop1,X_FD, by ="V1")

X_CO <- X_CO %>% mutate(V1 = as.integer(V1))
X_CO = inner_join(pop1,X_CO, by ="V1")

X_FD = column_to_rownames(X_FD, var = "V1")
X_FD <- replace(X_FD, is.na(X_FD), 0)

X_CO = column_to_rownames(X_CO, var = "V1")
X_CO <- replace(X_CO, is.na(X_CO), 0)


X = rbind(X_FD,X_CO) 


my_pca_FD <- prcomp(X_FD, scale. = TRUE)
my_pca_CO <- prcomp(X_CO, scale. = TRUE)
my_pca <- prcomp(X, scale. = TRUE)


# Création d'un data frame avec les coordonnées des deux premières composantes principales
df_FD <- data.frame(PC1 = my_pca_FD$x[,1], PC2 = my_pca_FD$x[,2], PC3 = my_pca_FD$x[,3], pere =X_FD$pere, mere = X_FD$mere)
df_CO <- data.frame(PC1 = my_pca_CO$x[,1], PC2 = my_pca_CO$x[,2], PC3 = my_pca_CO$x[,3], pere =X_CO$pere, mere = X_CO$mere)
df <- data.frame(PC1 = my_pca$x[,1], PC2 = my_pca$x[,2], PC3 = my_pca$x[,3], pere =X$pere, mere = X$mere)



df_FD_mere <- split(df_FD, df_FD$mere)
df_CO_mere <- split(df_CO, df_CO$mere)
df_mere <- split(df, df$mere)

# Tracé avec ggplot2
ggplot(df_FD, aes(x = PC1, y = PC2, color = pere)) + 
  geom_point() + geom_text(aes(label = pere), nudge_y = 0.1) + 
  geom_path(data = do.call(rbind, df_FD_mere), 
  aes(x = PC1, y = PC2, group = mere), linetype = "solid") +
    xlab("PC1") + 
  ylab("PC2") +
  ggtitle("PCA Plot FD")

 



ggplot(df_CO, aes(x = PC1, y = PC2, color = pere)) + 
  geom_point() + geom_text(aes(label = pere), nudge_y = 0.1) +
  geom_path(data = do.call(rbind, df_CO_mere), 
            aes(x = PC1, y = PC2, group = mere), linetype = "solid") +
  xlab("PC1") + 
  ylab("PC2") +
  ggtitle("PCA Plot CO")


ggplot(df, aes(x = PC1, y = PC2, color = pere)) + 
  geom_point() + geom_text(aes(label = pere), nudge_y = 0.1) +
  geom_path(data = do.call(rbind, df_mere), 
            aes(x = PC1, y = PC2, group = mere), linetype = "solid")+
  xlab("PC1") + 
  ylab("PC2") +
  ggtitle("PCA Plot all")



var_exp_FD <- 100*(my_pca_FD$sdev^2 / sum(my_pca_FD$sdev^2))
df_var_exp_FD <- data.frame(PC = paste0("PC", 1:length(var_exp_FD)), Var_Exp = var_exp_FD)
df_var_exp_top50_FD <- df_var_exp_FD[1:50,]/ 

# Tracé avec ggplot2, trié en ordre décroissant de variance expliquée
ggplot(df_var_exp_top50_FD, aes(x = reorder(PC, -Var_Exp), y = Var_Exp)) + 
  geom_bar(stat = "identity", fill = "steelblue") + 
  xlab("Composante Principale") + 
  ylab("Variance Expliquée (%)") +
  ggtitle("Variance Expliquée par chaque Composante Principale pour FD")
