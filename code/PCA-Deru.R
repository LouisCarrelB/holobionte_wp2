X_FD = fread(paste0(path_output,"FD_gen.txt.gz"))
X_CO = fread(paste0(path_output,"CO_gen.txt.gz"))


pheno <- fread(paste0(path_pheno,"donnees_phenotypes.txt"))
pop1 <- data.frame(pheno$regime)
rownames(pop1) = pheno$numero_animal