#Pour le génome : 





path_pheno = "./data/Vanille_Deru/donnees_pheno/"

path_simu = "./data/Vanille_Deru/simulation/"
path_output = "./data/Vanille_Deru/simulation/"
B_raw = read.table(paste0(path_simu,'bacteria_1.txt.gz'), header=T)
X_raw = read.table(paste0(path_simu,'gen.txt.gz'),  header=T)
pheno <- fread(paste0(path_pheno,"donnees_phenotypes.txt"
                      
                      
                      
                      
noms_lignes_communs <- intersect(rownames(X_raw), rownames(B_raw))

X_communs <- X_raw[noms_lignes_communs, ]
B_communs <- B_raw[noms_lignes_communs, ]

write.table(B_communs, file = gzfile(paste0(path_output,"bacteria.txt.gz")), sep = "\t", 
            col.names = TRUE, row.names = TRUE, quote = TRUE, 
)

write.table(X_communs, file = gzfile(paste0(path_output,"gen.txt.gz")), sep = "\t", 
            col.names = TRUE, row.names = TRUE, quote = TRUE, 
)
