
library('tictoc')
#--> BayesC, WARNING: can take long to run and writes big files
probin=0.001
p0=5
tictoc::tic()
fm_Cgb = doBayesC(yNA, X=X, B=B, out='bayCgb_', pi1=probin, pi2=probin, p0=p0)
fm_Cg = doBayesC(yNA, X=X, out='bayCg_', pi1=probin, p0=p0)
fm_Cb = doBayesC(yNA, B=B, out='bayCb_', pi2=probin, p0=p0)
c = list('fm_Cgb'=fm_Cgb,'fm_Cg'=fm_Cg,'fm_Cb'=fm_Cb)
save(c,file='fmc.Rdata')
tictoc::toc()

install.packages(tictoc)
library(tictoc)


# postprocess Bayes C results
load('simubiome.Rdata')
load('fmc.Rdata')
# predictive accuracy in Bayes Cgb
y = s$y
# recover missing if needed
ytst = c$fm_Cgb$fm$y
tst = which(is.na(ytst))

yhat_Cgb = c$fm_Cgb$fm$yHat[tst]
rho = cor(c$fm_Cgb$fm$yHat[tst], y[tst])
# plot y yhat
plot(y[tst], c$fm_Cgb$fm$yHat[tst], xlab='Observed y', ylab='Predicted y')

# computes h2, b2 and cov(g,b)
G=readBinMat('bayCgb_ETA_1_b.bin')
C=readBinMat('bayCgb_ETA_2_b.bin')
u=G%*%t(X)
b=C%*%t(B)
Y=matrix(rep(y,nrow(G)), nrow = nrow(G), byrow=TRUE)
varU=apply(u,1,var)
varB=apply(b,1,var)
covUB=(apply(u+b,1,var) - varU - varB)*0.5
varE=apply(Y-u-b,1,var)
h2g=varU/(varU+varB+varE)
h2b=varB/(varU+varB+varE)
h2gb=covUB/(varU+varB+varE)
# plots
plot(density(h2g),xlim=c(-0.05,1),main=c('Bayes Cgb',rho),xlab='var component')
lines(density(h2b),col='blue',lty=2)
lines(density(h2gb),col='red',lty=3)
print(c(mean(h2g),mean(h2b),mean(h2gb)))

