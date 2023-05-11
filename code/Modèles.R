## @knitr Modele

library('BGLR')
load(paste0(path_RDS,'simubiome.Rdata'))
pca_kmeans_g = readRDS(paste0(path_RDS,"pca_kmeans.RDS"))
pca_kmeans_b = readRDS(paste0(path_RDS,"pca_kmeans_b.RDS"))

#--> scale and transpose data
X = scale(t(s$X))
B = scale(t(s$B))
y = scale(s$y)


probin=0.001
p0=5
 
for (CV in c("hasard","Micro","Géno")) {

  if (CV == "hasard") {
    
    fold = sample(1:10,length(y), replace = TRUE)
    a_all = vector("list",10)
    a_times = vector("list",10)
    for (i in 1:10) {
    tst = which(fold == i)
    yNA = y 
    yNA[tst]= NA
    tictoc::tic()
    fm_Ggb <- doBayesC(yNA, X = X, B = B, out = 'bayCgb_', pi1 = probin, pi2 = probin, p0 = p0)
    a_times[[i]] <- tictoc::toc()
    fm_Gg = doBayesC(yNA, X=X, out='bayCg_', pi1=probin, p0=p0)
    fm_Gb = doBayesC(yNA, B=B, out='bayCb_', pi2=probin, p0=p0)
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
      fm_Ggb = doBayesC(yNA, X=X, B=B, out='bayCgb_', pi1=probin, pi2=probin, p0=p0)
      fm_Gg = doBayesC(yNA, X=X, out='bayCg_', pi1=probin, p0=p0)
      fm_Gb = doBayesC(yNA, B=B, out='bayCb_', pi2=probin, p0=p0)
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
      fm_Ggb = doBayesC(yNA, X=X, B=B, out='bayCgb_', pi1=probin, pi2=probin, p0=p0)
      fm_Gg = doBayesC(yNA, X=X, out='bayCg_', pi1=probin, p0=p0)
      fm_Gb = doBayesC(yNA, B=B, out='bayCb_', pi2=probin, p0=p0)
      b = list('tst'=tst,'fm_Ggb'=fm_Ggb,'fm_Gg'=fm_Gg,'fm_Gb'=fm_Gb)
      b_all[[cluster]] = b
      
    }
  saveRDS(b_all,paste0(path_RDS,"b_",regime,".RDS"))
  }
  
}


  