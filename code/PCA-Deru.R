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
my_pca_FD <- prcomp(X_FD[,-c(1,2)], scale. = TRUE)
my_pca_CO <- prcomp(X_CO[,-c(1,2)], scale. = TRUE)
my_pca <- prcomp(X[,-c(1,2)], scale. = TRUE)
saveRDS(my_pca_FD,"~/work/holobionte_wp2/data/RDS/my_pca_FD.RDS")
saveRDS(my_pca_CO,"~/work/holobionte_wp2/data/RDS/my_pca_CO.RDS")
saveRDS(my_pca,"~/work/holobionte_wp2/data/RDS/my_pca.RDS")
} else {
  my_pca_FD = readRDS("~/work/holobionte_wp2/data/RDS/my_pca_FD.RDS")
  my_pca_CO= readRDS("~/work/holobionte_wp2/data/RDS/my_pca_CO.RDS")
  my_pca = readRDS("~/work/holobionte_wp2/data/RDS/my_pca.RDS")}


# Création d'un data frame avec les coordonnées des trois premières composantes principales
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
df_var_exp_top90 <- df_var_exp[1:90,] 

var_exp_regime <- 100*(get(paste0("my_pca_",regime))$sdev^2 / sum(get(paste0("my_pca_",regime))$sdev^2))
df_var_exp_regime <- data.frame(PC = paste0("PC", 1:length(var_exp_regime)), Var_Exp = var_exp_regime)
df_var_exp_top90_regime <- df_var_exp_regime[1:90,] 

ggplot(df_var_exp_top90, aes(x = reorder(PC, -Var_Exp), y = Var_Exp)) + 
  geom_bar(stat = "identity", fill = "steelblue") + 
  xlab("Composante Principale") + 
  ylab("Variance Expliquée (%)") +
  ggtitle("Variance Expliquée par chaque Composante Principale")

ggplot(df_var_exp_top90_regime, aes(x = reorder(PC, -Var_Exp), y = Var_Exp)) + 
  geom_bar(stat = "identity", fill = "steelblue") + 
  xlab("Composante Principale") + 
  ylab("Variance Expliquée (%)") +
  ggtitle(paste("Variance Expliquée par chaque Composante Principale pour le régime",regime))


# For Microbiota 


B_FD = readRDS(paste0(path_output,"FD_bacteria.rds"))
B_CO = readRDS(paste0(path_output,"CO_bacteria.rds"))
B_FD <- replace(B_FD, is.na(B_FD), 0)
B_CO <- replace(B_CO, is.na(B_CO), 0)
B = rbind(B_FD,B_CO) 


vars_to_remove_FD <- names(B_FD)[apply(B_FD, 2, var) < 1e-11]
vars_to_remove_CO <- names(B_CO)[apply(B_CO, 2, var) < 1e-11]
vars_to_remove <- names(B)[apply(B, 2, var) < 1e-11]

# Supprimer les variables avec une variance nulle ou très faible
B_FD <- B_FD[, !names(B_FD) %in% vars_to_remove_FD]
B_CO <- B_CO[, !names(B_CO) %in% vars_to_remove_CO]
B <- B[, !names(B) %in% vars_to_remove]


if (file.exists("~/work/holobionte_wp2/data/RDS/my_pca_b.RDS") == FALSE){
  my_pca_FD_b <- prcomp(B_FD, scale. = TRUE)
  my_pca_CO_b <- prcomp(B_CO, scale. = TRUE)
  my_pca_b <- prcomp(B, scale. = TRUE)
  saveRDS(my_pca_FD_b,"~/work/holobionte_wp2/data/RDS/my_pca_FD_b.RDS")
  saveRDS(my_pca_CO_b,"~/work/holobionte_wp2/data/RDS/my_pca_CO_b.RDS")
  saveRDS(my_pca_b,"~/work/holobionte_wp2/data/RDS/my_pca_b.RDS")
} else {
  my_pca_FD_b = readRDS("~/work/holobionte_wp2/data/RDS/my_pca_FD_b.RDS")
  my_pca_CO_b= readRDS("~/work/holobionte_wp2/data/RDS/my_pca_CO_b.RDS")
  my_pca_b = readRDS("~/work/holobionte_wp2/data/RDS/my_pca_b.RDS")}



# Tracé avec ggplot2, trié en ordre décroissant de variance expliquée

var_exp_b <- 100*(my_pca_b$sdev^2 / sum(my_pca_b$sdev^2))
df_var_exp_b <- data.frame(PC = paste0("PC", 1:length(var_exp)), Var_Exp = var_exp)
df_var_exp_top90_b <- df_var_exp[1:90,] 

var_exp_regime_b <- 100*(get(paste0("my_pca_",regime,"_b"))$sdev^2 / sum(get(paste0("my_pca_",regime,"_b"))$sdev^2))
df_var_exp_regime_b <- data.frame(PC = paste0("PC", 1:length(var_exp_regime)), Var_Exp = var_exp_regime)
df_var_exp_top90_regime_b <- df_var_exp_regime[1:90,] 

ggplot(df_var_exp_top90_b, aes(x = reorder(PC, -Var_Exp), y = Var_Exp)) + 
  geom_bar(stat = "identity", fill = "steelblue") + 
  xlab("Composante Principale") + 
  ylab("Variance Expliquée (%)") +
  ggtitle("Variance Expliquée par chaque Composante Principale pour le microbiote")

ggplot(df_var_exp_top90_regime_b, aes(x = reorder(PC, -Var_Exp), y = Var_Exp)) + 
  geom_bar(stat = "identity", fill = "steelblue") + 
  xlab("Composante Principale") + 
  ylab("Variance Expliquée (%)") +
  ggtitle(paste("Variance Expliquée par chaque Composante Principale du microbiote pour le régime",regime))



