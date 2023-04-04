
library('BGLR')
load(paste0(WORKING_DIR,'simubiome.Rdata'))
pca_kmeans_g = readRDS(paste0(path_RDS,"pca_kmeans.RDS"))
pca_kmeans_b = readRDS(paste0(path_RDS,"pca_kmeans_b.RDS"))

#--> scale and transpose data
X = scale(t(s$X))
B = scale(t(s$B))
y = scale(s$y)



if (CV == "hasard") {
  n_iter <- 10
  a_all = vector("list",10)
  
  # sélectionner les indices à remplacer par NA pour la première itération
  tst <- sample(seq_along(y), size = floor(length(y) / n_iter), replace = FALSE)
  
  for (i in 1:n_iter) {
    
    yNA = y
    yNA[tst] = NA
    
    # retirer les index de tst correspondant aux valeurs manquantes générées
    tst <- setdiff(tst, which(is.na(yNA)))
    
    # si ce n'est pas la dernière itération, sélectionner les nouveaux index manquants
    if (i < n_iter) {
      new_tst <- sample(setdiff(seq_along(y), tst), size = floor(length(y) / n_iter), replace = FALSE)
      tst <- c(tst, new_tst)
    }
    
    fm_Ggb = doGBLUP(yNA, X, B, out='gblupgb_')
    fm_Gg = doGBLUP(yNA, X=X, out='gblupg_')
    fm_Gb = doGBLUP(yNA, B=B, out='gblupb_')
    a = list('tst'=tst,'fm_Ggb'=fm_Ggb,'fm_Gg'=fm_Gg,'fm_Gb'=fm_Gb)
    a_all[[i]] = a
  }

  saveRDS(a_all,paste0(path_RDS,"a_",regime,".RDS"))
  }



if (CV == "Géno") {
  g_all = vector("list",10)
  
  for (cluster in 1:10){
    
    yNA = y
    yNA[which(pca_kmeans_g$cluster == cluster)] = NA
    tst = which(is.na(yNA))
    fm_Ggb = doGBLUP(yNA, X, B, out='gblupgb_')
    fm_Gg = doGBLUP(yNA, X=X, out='gblupg_')
    fm_Gb = doGBLUP(yNA, B=B, out='gblupb_')
    g = list('tst'=tst,'fm_Ggb'=fm_Ggb,'fm_Gg'=fm_Gg,'fm_Gb'=fm_Gb)
    g_all[[cluster]] = g
    
  }
  saveRDS(g_all,paste0(path_RDS,"g_",regime,".RDS"))
}

if (CV == "Micro"){
  b_all = vector("list",10)
  
  for (cluster in 1:10){
    
    yNA = y
    yNA[which(pca_kmeans_b$cluster == cluster)] = NA
    tst = which(is.na(yNA))
    fm_Ggb = doGBLUP(yNA, X, B, out='gblupgb_')
    fm_Gg = doGBLUP(yNA, X=X, out='gblupg_')
    fm_Gb = doGBLUP(yNA, B=B, out='gblupb_')
    b = list('tst'=tst,'fm_Ggb'=fm_Ggb,'fm_Gg'=fm_Gg,'fm_Gb'=fm_Gb)
    b_all[[cluster]] = b
    
  }
  saveRDS(b_all,paste0(path_RDS,"b_",regime,".RDS"))
}
  