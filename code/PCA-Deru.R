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

if (file.exists("~/work/holobionte_wp2/data/RDS/my_pca.RDS") == FALSE){
my_pca_FD <- prcomp(X_FD, scale. = TRUE)
my_pca_CO <- prcomp(X_CO, scale. = TRUE)
my_pca <- prcomp(X, scale. = TRUE)} else {
  my_pca_FD = readRDS("~/work/holobionte_wp2/data/RDS/my_pca_FD.RDS")
  my_pca_CO= readRDS("~/work/holobionte_wp2/data/RDS/my_pca_CO.RDS")
  my_pca = readRDS("~/work/holobionte_wp2/data/RDS/my_pca.RDS")}


# Création d'un data frame avec les coordonnées des deux premières composantes principales
df_FD <- data.frame(PC1 = my_pca_FD$x[,1], PC2 = my_pca_FD$x[,2], PC3 = my_pca_FD$x[,3], pere =X_FD$pere, mere = X_FD$mere)
df_CO <- data.frame(PC1 = my_pca_CO$x[,1], PC2 = my_pca_CO$x[,2], PC3 = my_pca_CO$x[,3], pere =X_CO$pere, mere = X_CO$mere)
df <- data.frame(PC1 = my_pca$x[,1], PC2 = my_pca$x[,2], PC3 = my_pca$x[,3], pere =X$pere, mere = X$mere)



df_FD_mere <- split(df_FD, df_FD$mere)
df_CO_mere <- split(df_CO, df_CO$mere)
df_mere <- split(df, df$mere)


if (regime == "CO") {df_regime = df_CO 
df_regime_mere = df_CO_mere}
if (regime == "FD") {df_regime = df_FD 
df_regime_mere = df_FD_mere}

# Tracé avec ggplot2 pour un régime 
ggplot(df_regime, aes(x = PC1, y = PC2, color = pere)) + 
  geom_point() + geom_text(aes(label = pere), nudge_y = 0.1) + 
  geom_path(data = do.call(rbind, df_regime_mere), 
  aes(x = PC1, y = PC2, group = mere), linetype = "solid") +
    xlab("PC1") + 
  ylab("PC2") +
  ggtitle(paste0("PCA Plot "),regime)

 

# Tracé avec ggplot2 pour les deux régimes
ggplot(df, aes(x = PC1, y = PC2, color = pere)) + 
  geom_point() + geom_text(aes(label = pere), nudge_y = 0.1) +
  geom_path(data = do.call(rbind, df_mere), 
            aes(x = PC1, y = PC2, group = mere), linetype = "solid")+
  xlab("PC1") + 
  ylab("PC2") +
  ggtitle("PCA Plot all")


# Tracé avec ggplot2, trié en ordre décroissant de variance expliquée

var_exp <- 100*(my_pca$sdev^2 / sum(my_pca$sdev^2))
df_var_exp <- data.frame(PC = paste0("PC", 1:length(var_exp)), Var_Exp = var_exp)
df_var_exp_top50 <- df_var_exp[1:50,] 

ggplot(df_var_exp_top50, aes(x = reorder(PC, -Var_Exp), y = Var_Exp)) + 
  geom_bar(stat = "identity", fill = "steelblue") + 
  xlab("Composante Principale") + 
  ylab("Variance Expliquée (%)") +
  ggtitle("Variance Expliquée par chaque Composante Principale")
