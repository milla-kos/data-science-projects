
library(tidyverse)
library(insight)
library(stargazer)
library(dendextend)
library(ggplot2)
library(gridExtra)

mortality <- read.csv("oecd_mortality_diseases.csv")
mortality <- data.frame(country = mortality$REF_AREA, death_cause = mortality$DEATH_CAUSE, val = mortality$OBS_VALUE)

index <- order(mortality$country, mortality$death_cause)
ordered <- mortality[index,]

causes <- c("CIRC", "DIGE", "ENDO", "INFE", "NEOP", "NERV", "RESP", "BLOOD", "MENT")
countries <- unique(ordered$country)
mortality_matrix <- matrix(c(ordered[,3]), nrow = length(countries), byrow = TRUE, 
                    dimnames = list(countries,causes))
mortality_scaled <- scale(mortality_matrix)

# max mortality rates in each country and for each disease
mortality_countries <- max.col(mortality_matrix)
mortality_causes <- max.col(t(mortality_matrix))

max_cause <- data.frame(Country = countries, Cause = causes[mortality_countries], 
                        Rate = apply(mortality_matrix, 1, max, na.rm=TRUE))
max_country <- data.frame(Cause = causes, Country = countries[mortality_causes], 
                          Rate = apply(mortality_matrix, 2, max, na.rm=TRUE))

# export tables
stargazer(t(max_cause), summary = FALSE, out = "max_cause.tex")
stargazer(max_country, summary = FALSE, out = "max_country.tex")

# export table of descriptive statistics
summ <- stargazer(mortality_matrix, summary = TRUE, out = "summary.tex", median = TRUE)

# scatter plot
pairs(mortality_matrix, upper.panel = NULL, cex = 0.8, gap = 0)

# clustering 
method <- "complete"
dist <- dist(mortality_scaled, method = "euclidean")
cluster <- hclust(dist, method = method)
dend <- as.dendrogram(cluster)

# plot dendrogram
plot(dend, xlab = "",
     ylab = "Tree height (Euclidean distance)",
     sub = NA, hang = -1)


# form clusters and plot dendrogram
h = 6.6
dend <- color_labels(dend, h = h,
                     col = c("red","lightgreen", "purple", "cornflowerblue"))
dend <- color_branches(dend, h = h,
                       col = c("red","lightgreen", "purple", "cornflowerblue"))
plot(dend, xlab = "",
     ylab = "Tree height (Euclidean distance)",
     sub = NA, hang = -1)

# scatter plot with clusters
clusters <- cutree(dend, h = h)
pairs(mortality_matrix, upper.panel = NULL, cex = 1, pch = 16, gap = 0, 
      col = c("cornflowerblue" ,"lightgreen", "purple", "red")[clusters])


# add cluster information to data
mortality_clusters <- as.data.frame(mortality_matrix)
mortality_clusters$cluster <- clusters


# boxplots of clusters
par(mfrow = c(3,3))

circ <- ggplot(mortality_clusters, aes(x=cluster, y=CIRC, fill=c("cluster 1", "cluster 2", "cluster 3", "cluster 4")[cluster])) + 
    geom_boxplot(alpha=0.9) +
    scale_fill_manual(values=c("cornflowerblue" ,"lightgreen", "purple", "red")) +
    theme(legend.position="none")

dige <- ggplot(mortality_clusters, aes(x=cluster, y=DIGE, fill=c("cluster 1", "cluster 2", "cluster 3", "cluster 4")[cluster])) + 
  geom_boxplot(alpha=0.9) +
  scale_fill_manual(values=c("cornflowerblue" ,"lightgreen", "purple", "red")) +
  theme(legend.position="none")

endo <- ggplot(mortality_clusters, aes(x=cluster, y=ENDO, fill=c("cluster 1", "cluster 2", "cluster 3", "cluster 4")[cluster])) + 
  geom_boxplot(alpha=0.9) +
  scale_fill_manual(values=c("cornflowerblue" ,"lightgreen", "purple", "red")) +
  theme(legend.position="none")

infe <- ggplot(mortality_clusters, aes(x=cluster, y=INFE, fill=c("cluster 1", "cluster 2", "cluster 3", "cluster 4")[cluster])) + 
  geom_boxplot(alpha=0.9) +
  scale_fill_manual(values=c("cornflowerblue" ,"lightgreen", "purple", "red")) +
  theme(legend.position="none")

neop <- ggplot(mortality_clusters, aes(x=cluster, y=NEOP, fill=c("cluster 1", "cluster 2", "cluster 3", "cluster 4")[cluster])) + 
  geom_boxplot(alpha=0.9) +
  scale_fill_manual(values=c("cornflowerblue" ,"lightgreen", "purple", "red")) +
  theme(legend.position="none")

nerv <- ggplot(mortality_clusters, aes(x=cluster, y=NERV, fill=c("cluster 1", "cluster 2", "cluster 3", "cluster 4")[cluster])) + 
  geom_boxplot(alpha=0.9) +
  scale_fill_manual(values=c("cornflowerblue" ,"lightgreen", "purple", "red")) +
  theme(legend.position="none")

resp <- ggplot(mortality_clusters, aes(x=cluster, y=RESP, fill=c("cluster 1", "cluster 2", "cluster 3", "cluster 4")[cluster])) + 
  geom_boxplot(alpha=0.9) +
  scale_fill_manual(values=c("cornflowerblue" ,"lightgreen", "purple", "red")) +
  theme(legend.position="none")

blood <- ggplot(mortality_clusters, aes(x=cluster, y=BLOOD, fill=c("cluster 1", "cluster 2", "cluster 3", "cluster 4")[cluster])) + 
  geom_boxplot(alpha=0.9) +
  scale_fill_manual(values=c("cornflowerblue" ,"lightgreen", "purple", "red")) +
  theme(legend.position="none")

ment <- ggplot(mortality_clusters, aes(x=cluster, y=MENT, fill=c("cluster 1", "cluster 2", "cluster 3", "cluster 4")[cluster])) + 
  geom_boxplot(alpha=0.9) +
  scale_fill_manual(values=c("cornflowerblue" ,"lightgreen", "purple", "red")) +
  theme(legend.position="none")

grid.arrange(circ,dige,endo,neop,infe,nerv,resp,blood,ment,nrow = 3)
