## @knitr Modele

library('BGLR')
load(paste0(path_RDS,'simubiome.Rdata'))
pca_kmeans_g = readRDS(paste0(path_RDS,"pca_kmeans.RDS"))
pca_kmeans_b = readRDS(paste0(path_RDS,"pca_kmeans_b.RDS"))

#--> scale and transpose data
X = scale(t(s$X))
B = scale(t(s$B))
y = scale(s$y)

for (CV in c("hasard","Micro","Géno")) {

  if (CV == "hasard") {
    
    fold = sample(1:10,length(y), replace = TRUE)
    a_all = vector("list",10)
    for (i in 1:10) {
    tst = which(fold == i)
    yNA = y 
    yNA[tst]= NA
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
  
}
  