#Pour le génome : 

library(snpStats)




path_pheno = "C:/Users/lcarrel/Nextcloud/pepr-holobionts-wp2/data/Vanille_Deru/donnees_pheno/"

path_simu = "C:/Users/lcarrel/Nextcloud/pepr-holobionts-wp2/data/Vanille_Deru/simulation/"
path_output = "C:/Users/lcarrel/Nextcloud/pepr-holobionts-wp2/data/Vanille_Deru/simulation/"
B_raw = read.table(paste0(path_simu,'bacteria_1.txt.gz'), header=T)
X_raw = read.table(paste0(path_simu,'gen_1.txt.gz'),  header=T)
pheno <- fread(paste0(path_pheno,"donnees_phenotypes.txt

B_raw2 <- B_raw[-c(1562:1564),] # Les 3 derniers individus ne sont pas dans le génome 

write.table(B_raw2, file = gzfile(paste0(path_output,"bacteria.txt.gz")), sep = "\t", 
            col.names = TRUE, row.names = TRUE, quote = TRUE, 
)

write.table(X_raw, file = gzfile(paste0(path_output,"gen.txt.gz")), sep = "\t", 
            col.names = TRUE, row.names = TRUE, quote = TRUE, 
)
