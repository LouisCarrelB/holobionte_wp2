## @knitr Cluster

PCA = my_pca$x
print(PCA)
my_pca_9PCs <- PCA[,1:9]

print(my_pca_9PCs)
pca_kmeans = kmeans(my_pca_9PCs,10)

print(pca_kmeans)
#Create data frame with PC1 and PC2 columns
df <- data.frame(PC1 = my_pca$x[,1], PC2 = my_pca$x[,2], cluster =  factor(pca_kmeans$cluster), pere =X$pere, mere = X$mere)

print(df)
# Create scatterplot with color-coded clusters
ggplot(df, aes(x = PC1, y = PC2, color = cluster)) +
  geom_point() +
  scale_color_discrete(name = "Cluster") +
  ggtitle("PC1 par rapport à PC2 avec les clusters")


# Create complet scatterplot
ggplot(df, aes(x = PC1, y = PC2, color = cluster)) +
  geom_point() +
  scale_color_discrete(name = "Cluster") +
  geom_point() + geom_text(aes(label = pere), nudge_y = 0.1) +
  geom_path(data = do.call(rbind, df_mere), 
            aes(x = PC1, y = PC2, group = mere), linetype = "solid")+
  xlab("PC1") + 
  ylab("PC2") +
  ggtitle("PCA Plot all regime")
                               