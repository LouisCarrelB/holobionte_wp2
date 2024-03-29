##################################################################################
# simubiome functions
# Miguel Perez-Enciso (miguel.perez@uab.es)
##################################################################################


#!/usr/bin/env Rscript


#------------------------------
sortCorr <- function(x, y, rho) {
  #------------------------------
  # returns list of permuted positions in y s.t. cor(x,y[sortCorr(x,y,rho)])=rho
  z = sort(y) + rnorm(length(y), 0, sd=sqrt(var(y) * (1./(rho**2)-1.)) )
  iy = order(y)
  iy = iy[order(z)]
  iy = iy[rank(x)]
  return(iy)
}

#------------------------>  
read.gen = function(gfile) {
  #-------------------------
  # read genotypes

  if (data_use == data1) {
    gen = as.matrix(data.frame(fread(gfile, header=F)))
    n = ncol(gen)
  # sum alleles
  o = seq(1,n,2)
  e = seq(2,n,2)
  gen = t(gen[,o] + gen[,e])
  gen[gen==0]=NA
  gen=gen-2
  f = rowMeans(gen, na.rm=T)/2
  # replace missing with mean
  for (i in seq(length(f))) { gen[i,is.na(gen[i,])]=f[i]*2} }
  
  if (data_use == data2) { 
    gen = readRDS(gfile)
    n = ncol(gen)

    gen = t(gen)
    f = rowMeans(gen, na.rm=T)
    for (i in seq(length(f))) { gen[i,is.na(gen[i,])]=f[i]}
    }
  return(gen) 
}

#----------------------------
read.biome <- function(bfile) {
  #----------------------------
  # add pseudocount, do TSS and log, return transposed
  # bacteria or achaea
  if (data_use == data1) {bac = 
    as.matrix(data.frame(fread(bfile, drop=1, header=T)))}
  if (data_use ==data2) {
    bac = readRDS(bfile)
  }
  # add pseudocount
  bac[bac==0]=1
  # total sum scaling
  B = mapply(`/`, data.frame(t(bac)), rowSums(bac))*10000
  return(log(B))
}

#------------------------------------
doVar <- function(h2, b2, varg, varb) {
  #------------------------------------
  # adjust var(b) and var(e) st h2 condition is fulfilled
  if (h2>0) {
    varb = varg / h2 * b2
    vare = varg / h2 * (1-h2-b2)
  } else {
    vare = varb * (1-b2) / b2
  }
  return(list('vare'=vare, 'varb'=varb))
}

#####################################
##
h2u_sampler_function <- function(h2u_threshold = .4, h2u_quotient = 100) {
  function() { min(h2u_threshold, rgamma(1, shape = 3, scale = 3.5) / h2u_quotient) }
}

#####################################
##########   SimuBiome    ###########
#####################################
# include indirect snps on output
# Parameters:
#    Bclust : specifies clusters to sample from, all otus from the same cluster are jointly permuted
#    h2: h2 y 
#    Nqtl_y: n causal snps with direct effect on y
#    Notu_y: n otus with direct effect on y
#    Notu_y_g: n otus with genetic determinism that affect y (subset of Notu_y)
#    Nqtl_otu: n causal snps with direct effect on each otu_y_g
#    h2u_sampler: RNG for the heritability of the microbial abundance
#    y is directly affected then by Notu_y abundances and Nqtl_y snps
#    y is indirectly affected by (Notu_g * Nqtl_otu) snps
#
# Models
#    Indirect     g-->b-->y           ==> Nqtl_y=0, Notu_y>0, Notu_y_g>0, h2=0, b2>0
#    Microbiome   b-->y               ==> Nqtl_y=0, Notu_y>0, Notu_y_g=0, h2=0, b2>0
#    Independent  g-->y<--b           ==> Nqtl_y>0, Notu_y>0, Notu_y_g=0, h2>0, b2>0
#    Recursive     g-->y<--b<--g       ==> Nqtl_y>0, Notu_y>0, Notu_y_g>0, h2>0, b2>0
#    Genome       g-->y               ==> Nqtl_y>0, Notu_y=0, Notu_y_g=0, h2>0, b2=0
#    
# Input X, B
# Determine g: sample Nqtl and Nqtl_otu and effects from gamma
# Ouput
#    y: simulated phenotypes
#    B: permuted microbiome abundances
#    gq: individual genotypic values
#    gb: individual microbiome values
#    b_otu: otu coefficients
#    b_qtl: qtl coefficients
#    qtl_list: causative snp ids (positions in X)
#    otu_list: causative otu ids (positions in B)
#    otu_qtl_list: qtl affecting otus ids (positions in X)
#--------------------------------------------------------------------------------------------------------------
SimuBiome = function(X, B, Bclust=Bclust, h2=h2, b2=b2, Nqtl_y=Nqtl_y, Notu_y=Notu_y, Notu_y_g=Notu_y_g, permute = T, h2u_sampler = h2u_sampler_function()) {
  #--------------------------------------------------------------------------------------------------------------

  Deru_all <- data_use == data2 && regime == "all"
  if (Deru_all) {
    B_CO = B$B_CO
    B_FD = B$B_FD
    B = cbind(B_CO,B_FD)
    X_CO = X$X_CO
    X_FD = X$X_FD
    X = cbind(X_CO,X_FD)
    Notu = nrow(B_FD)+nrow(B_CO) }
  beta_otu = NULL
  beta_qtl = NULL
  Nind = ncol(X)
  Nsnp = nrow(X)
  Notu = nrow(B)
    if(is.null(Bclust)) {Bclust=seq(Notu)}
    Nclust = max(Bclust)

  try(if (Nind != ncol(B))   stop('Nind in B and X does not match'))
  try(if (Notu_y_g > Notu_y) stop('Notu_y must be >= Notu_y_g'))
  try(if (Notu_y_g > Nclust) stop('Nclust must be >= Notu_y_g'))
  
  # permute microbiomes
  if (permute) {
  if(Deru_all) {B_FD = B_FD[,sample(ncol(B_FD))]
  B_CO=B_CO[,sample(ncol(B_CO))]} else {B = B[,sample(ncol(B))]
  
}}
  # list of snps directly influencing y
  qtl_list  = sample(seq(Nsnp), size = Nqtl_y)
  
  # Reorder abundances and corresponding cluster such that otu h2 is as expected, given genotype values
  otu_list = c()
  otu_qtl_list = c()
  temp_list = seq(Notu)
  

  
  if (Notu_y_g>0) {
    # sample a list of clusters
    if (Deru_all) {
      cluster_list <- sample(Nclust)[1:Notu_y_g]

      
      for (iclus in cluster_list) {
        iotu <- sample(which(Bclust == iclus))[1]
        otu_list <- append(otu_list, iotu)
        z_CO <- B_CO[iotu, ]
        z_FD <- B_FD[iotu, ]
        # OTU qtl effects
        beta = rgamma(Nqtl_otu, shape = 0.2, scale = 5) * sample(c(1,-1), size=Nqtl_otu, replace = T)
        # positions
        pos = sample(seq(Nsnp), size=Nqtl_otu, replace = F)
        otu_qtl_list = append(otu_qtl_list, pos)
        # QTL genotypes for OTU
        Xg_CO = X_CO[pos,]
        Xg_FD = X_FD[pos,]
        # OTU h2 (up bound to 0.9)
        h2u = h2u_sampler()
        print(h2u)
        # reorder the whole cluster st cor(g,z)=sqrt(h2)
        for (diet in c("CO","FD")) {
          # indiv genetic values for otu
          g = as.vector(t(get(paste0("Xg_",diet))) %*% beta) # check dimensions
          # adjust Var(g) st Var(g)/Var(z) = h2 as sampled
          k = sqrt(var(get(paste0("z_",diet)))*h2u/var(g))
          g = g * k
          ix = sortCorr(g,get(paste0("z_",diet)),sqrt(h2u)) 
          for (iotu in which(Bclust ==iclus)) {
          z = get(paste0("B_",diet))[iotu,]
          assign(paste0("B_", diet),  replace(get(paste0("B_", diet)), iotu, value = z[ix])) 
      }
        }}
      X = cbind(X_CO,X_FD)
      B = cbind(B_CO,B_FD)}     else {
    cluster_list = sample(Nclust)[1:Notu_y_g]
    for (iclus in cluster_list) {

      # sample an otu within that cl0uster
      iotu = sample(which(Bclust==iclus))[1]
      otu_list = append(otu_list, iotu)
      # abundances
      z = B[iotu,]
      # OTU qtl effects
      beta = rgamma(Nqtl_otu, shape = 0.2, scale = 5) * sample(c(1,-1), size=Nqtl_otu, replace = T)
      # positions
      pos = sample(seq(Nsnp), size=Nqtl_otu, replace = F)
      otu_qtl_list = append(otu_qtl_list, pos)
      # QTL genotypes for OTU
      Xg = X[pos,]
      # OTU h2 (up bound to 0.9)
      h2u = h2u_sampler()
      print(h2u)
      # indiv genetic values for otu
      g = as.vector(t(Xg) %*% beta) # check dimensions
      # adjust Var(g) st Var(g)/Var(z) = h2 as sampled
      k = sqrt(var(z)*h2u/var(g))
      g = g * k
      # reorder the whole cluster st cor(g,z)=sqrt(h2)
      ix = sortCorr(g,z,sqrt(h2u))
      for (iotu in which(Bclust==iclus)) {
        z = B[iotu,]
        B[iotu,] = z[ix]
      }
    }}
    temp_list = temp_list[-otu_list]
    }
  # if needed, complete otu list with non genetically determined otus
  if ((Notu_y-Notu_y_g)>0) {
    temp = sample(temp_list)[1:(Notu_y-Notu_y_g)]
    otu_list = append(otu_list, temp)
  }
  
  # simulates target variable, mediated by snps and/or otus
  # gamma mean=shape * scale; var=shape*scale**2
  # init
  gb = rep(0,Nind)
  gq = gb
  
  # SNP part
  if (Nqtl_y>0) {
    beta_qtl = rgamma(Nqtl_y, shape = 0.4, scale = 5) * sample(c(1,-1), size=Nqtl_y, replace = T)
    gq = t(X[qtl_list,]) %*% beta_qtl
  }
  
  # OTU part    
  if(Notu_y>0){
    beta_otu = rgamma(Notu_y, shape = 1.4, scale = 3.8) * sample(c(1,-1), size=Notu_y, replace = T)
    Botu = B[otu_list,]
    gb = t(Botu) %*% beta_otu
  }
  
  # scale gb and get ve st h2 and b2 as specified
  v = doVar(h2,b2,var(gq),var(gb))
  se = sqrt(v$vare)[1]
  if(b2>0) gb = (gb / sqrt(var(gb))[1]) * sqrt(v$varb[1])
  # just in case h2=0
  if (h2==0) gq = gq*h2
  y = gq + gb + rnorm(length(gq), 0, se)
  return(list('y'=y,'X' = X, 'B'=B, 'gq'=gq, 'gb'=gb, 'b_otu'=beta_otu, 'b_qtl'=beta_qtl, 
              'qtl_list'=qtl_list, 'otu_list'=otu_list, 
              'otu_qtl_list'=otu_qtl_list))

}

#----------------------------------------------------------------------------------
doBayesC = function(y,X=NULL,B=NULL,p0=5,pi1=0.001,pi2=0.001,out='bayc_',nIter=4e3 , burnIn = 300) {
  #----------------------------------------------------------------------------------
  # perform Bayes C
  # probin is p of entering with variance pi*(1-pi)/(p0+1)
  # p and counts such that expected in variables is 0.01 with large variance
  ETA = list()
  counter=0
  if (!is.null(X)) {
    counter=counter+1
    ETA[[counter]]= list(X=X, model='BayesC', probIn=pi1, counts=p0, saveEffects=TRUE)
  }
  if (!is.null(B)) {
    counter=counter+1
    ETA[[counter]] = list(X=B, model='BayesC', probIn=pi2, counts=p0, saveEffects=TRUE)
  }
  fm = BGLR(y=y, ETA=ETA, nIter=nIter, saveAt=out, verbose=F, burnIn = burnIn)
  varE=scan(paste0(out,'varE.dat'))
  return(list('fm'=fm, 'varE'=varE))
}

#------------------------------------------------------
doGBLUP = function(y,X=NULL,B=NULL,out='gblup_',flat=F) {
  #------------------------------------------------------
  # performs GBLUP (not used in original paper)
  nIter = 5e4
  if (flat) out=paste0(out,'flat_')
  h2_g = NULL
  h2_b = NULL
  ETA = list()
  nombres=as.character()
  counter=0
  if (!is.null(X)) {
    counter=counter+1
    G = tcrossprod(X) / ncol(X)
    if (flat) {
      ETA[[counter]] = list(K=G,model='RKHS',df0=0.0001,S0=0.0001)
    } else {
      ETA[[counter]] = list(K=G,model='RKHS')
    }
    nombres[counter]="G"
  }
  if (!is.null(B)) {
    counter = counter+1
    BB = tcrossprod(B) / ncol(B)
    if (flat) {
      ETA[[counter]] = list(K=BB,model='RKHS',df0=0.0001,S0=0.0001)
    } else {
      ETA[[counter]] = list(K=BB,model='RKHS')
    }
    ETA[[counter]]=list(K=BB,model='RKHS')
    nombres[counter]="B"
  }
  names(ETA)=nombres
  
  if (flat) {
    fm = BGLR(y=y, ETA=ETA, nIter=nIter, df0=0.0001, S0=0.0001, saveAt=out, verbose=F)
  } else {
    fm = BGLR(y=y, ETA=ETA, nIter=nIter, saveAt=out, verbose=F)
  }
  varE=scan(paste0(out,'varE.dat'))
  varY=varE
  if (!is.null(X)) {
    varU=scan(paste0(out,'ETA_G_varU.dat'))
    varY=varY+varU
  }
  if (!is.null(B)) {
    varB=scan(paste0(out,'ETA_B_varU.dat'))
    varY=varY+varB
  }
  if (!is.null(X)) {h2_g=varU/varY}
  if (!is.null(B)) {h2_b=varB/varY}
  return(list('fm'=fm, 'h2g'=h2_g, 'h2b'=h2_b))
}
  
  
  