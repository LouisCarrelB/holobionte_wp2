args = commandArgs(trailingOnly=TRUE)
scenario = args[1]
run = args[2]
cluster = args[3]


# folder containing snp and otu data
data1 = "/home/lcarrel/work/holobionte_wp2/data/Pérez/" #PEREZ
data2 = "/home/lcarrel/work/holobionte_wp2/data/Vanille_Deru/simulation/" # VANILLE DERU

#### PACKAGES AND LIBRARY
library('BGLR')
library('tictoc')
path_RDS = paste0("~/work/holobionte_wp2/data/RDS/",scenario,"/",as.character(run),"/")
####


source("~/work/holobionte_wp2/code/Simubiome.R")
source("~/work/holobionte_wp2/code/Params.R")


if (!file.exists(paste0(path_RDS,"Time_Modelisaton_fold_",cluster))) {

load(paste0(path_RDS,'simubiome.Rdata'))
pca_kmeans_g = readRDS(paste0(path_RDS,"pca_kmeans.RDS"))
pca_kmeans_b = readRDS(paste0(path_RDS,"pca_kmeans_b.RDS"))

#--> scale and transpose data
X = scale(t(s$X))
B = scale(t(s$B))
y = scale(s$y)


probin=0.001
p0=5
 
#CV hasard


if (regime ==  "all") {
  B_CO = read.biome(paste0(data_use,'CO_bacteria.rds'))
  B_FD =read.biome(paste0(data_use,'FD_bacteria.rds'))
  # We try to have the same number of animals of each diet in our folds
  fold_CO = sample(1:10,length(colnames(B_CO)), replace = TRUE)
  fold_FD = sample(1:10,length(colnames(B_FD)), replace = TRUE)
  fold = c(fold_CO,fold_FD)
} else {
    fold = sample(1:10,length(), replace = TRUE)}





    tst = which(fold == cluster)
    yNA = y 
    yNA[tst]= NA
tictoc::tic()



    fm_Ggb <- doBayesC(yNA, X = X, B = B, out = 'bayCgb_', pi1 = probin, pi2 = probin, p0 = p0)
    fm_Gg = doBayesC(yNA, X=X, out='bayCg_', pi1=probin, p0=p0)
    fm_Gb = doBayesC(yNA, B=B, out='bayCb_', pi2=probin, p0=p0)
    a = list('tst'=tst,'fm_Ggb'=fm_Ggb,'fm_Gg'=fm_Gg,'fm_Gb'=fm_Gb)

  
    saveRDS(a,paste0(path_RDS,as.character(cluster),"/","a_",regime,"_",cluster,".RDS"))

  
print("Temps de calcul de BayeC pour les clusters aléatoire pour chaque run : ")



#CV Géno  

    
      
      yNA = y
      yNA[which(pca_kmeans_g$cluster == cluster)] = NA
      tst = which(is.na(yNA))
      fm_Ggb = doBayesC(yNA, X=X, B=B, out='bayCgb_', pi1=probin, pi2=probin, p0=p0)
      fm_Gg = doBayesC(yNA, X=X, out='bayCg_', pi1=probin, p0=p0)
      fm_Gb = doBayesC(yNA, B=B, out='bayCb_', pi2=probin, p0=p0)
      g = list('tst'=tst,'fm_Ggb'=fm_Ggb,'fm_Gg'=fm_Gg,'fm_Gb'=fm_Gb)
      
    saveRDS(g,paste0(path_RDS,as.character(cluster),"/","g_",regime,"_",cluster,".RDS"))

    
#CV Micro
  


      
      yNA = y
      yNA[which(pca_kmeans_b$cluster == cluster)] = NA
      tst = which(is.na(yNA))
      fm_Ggb = doBayesC(yNA, X=X, B=B, out='bayCgb_', pi1=probin, pi2=probin, p0=p0)
      fm_Gg = doBayesC(yNA, X=X, out='bayCg_', pi1=probin, p0=p0)
      fm_Gb = doBayesC(yNA, B=B, out='bayCb_', pi2=probin, p0=p0)
      b = list('tst'=tst,'fm_Ggb'=fm_Ggb,'fm_Gg'=fm_Gg,'fm_Gb'=fm_Gb)

      
  saveRDS(b,paste0(path_RDS,as.character(cluster),"/","b_",regime,"_",cluster,".RDS"))

  
  
  

  
# CV Diet 
if (Diet == T) {
  #Only nee two fold so cluster 1 and 2 are enough
  
  if (cluster == 1 || cluster == 2) {
  yNA = y
if (cluster == 1) {yNA[1:length(colnames(B_CO))] = NA
  } else {yNA[length(colnames(B_CO)):length(rownames(B))] = NA}
tst = which(is.na(yNA))
fm_Ggb = doBayesC(yNA, X=X, B=B, out='bayCgb_', pi1=probin, pi2=probin, p0=p0)
fm_Gg = doBayesC(yNA, X=X, out='bayCg_', pi1=probin, p0=p0)
fm_Gb = doBayesC(yNA, B=B, out='bayCb_', pi2=probin, p0=p0)
d = list('tst'=tst,'fm_Ggb'=fm_Ggb,'fm_Gg'=fm_Gg,'fm_Gb'=fm_Gb)
saveRDS(d,paste0(path_RDS,as.character(cluster),"/","d_",regime,"_",cluster,".RDS"))


}}
  
times = tictoc::toc()

saveRDS(times, paste0(path_RDS,"Time_Modelisaton_fold_",cluster))




# Liste tous les fichiers du répertoire
fichiers <- list.files(paste0(path_RDS,"/",as.character(cluster)))
for (fichier in fichiers) {
  if (grepl("^BayCg", fichier)) {
    chemin_fichier <- file.path(paste0(path_RDS,fold), fichier)
    file.remove(chemin_fichier)
  }
}

}