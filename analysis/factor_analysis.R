setwd('/Users/paul/Documents/_Studium/Master Inf/Thesis/code/pilot-study')

test_scales = c('test_A', 'test_C', 'test_I')
mvs_scales = c('intrinsic', 'integrated', 'identified', 'introjected', 'external', 'amotivation')

data = read.csv("data/raw_answers.csv", sep=";", header=T)
num_total = nrow(data)

factor_cols <- c("mvs_check", "comp_check", "preferred")
data[factor_cols] <- lapply(data[factor_cols], factor)

data = data[data$comp_check=='1',]  # filter out failing the check
data = data[data$mvs_check=='1',]  # filter out failing the check
data = data[ , !(names(data) %in% c("comp_check", "mvs_check"))]  # drop these columns
data_raw = data[ , !(names(data) %in% c(test_scales, mvs_scales, 'preferred', 'preferred_simple'))]  # drop these columns
data_raw = data_raw[ , !(names(data_raw) %in% c('gcos_0_check', 'gcos_0_check.1', 'gcos_0_check.2', 'gcos_10_check', 'gcos_10_check.1', 'gcos_10_check.2'))]  # drop these columns

data_raw_raw = data_raw[ , !(names(data_raw) %in% c('pref_A_over_C', 'pref_I_over_BL', 'pref_C_over_I', 'pref_A_over_I'))]

bin_low_mid_high = function(data, scales) {
  lapply(data[scales], function(col) {
    # cut into <25%, 25-75%, 75%<
    c = cut(col,  breaks=c(0, quantile(col, probs=c(0.25, 0.75), na.rm=TRUE), max(col)))
    # map to integer factors
    #mapvalues(c, from = levels(c), to = seq(1, 3))
    c
  })
}

library(plyr)
bin_low_high = function(data, scales) {
  lapply(data[scales], function(col) {
    c = cut(col,  breaks=c(0, quantile(col, probs=c(0.75), na.rm=TRUE), max(col)))
    mapvalues(c, from = levels(c), to = seq(1, 2))
  })
}

mvs_scales_high = unlist(lapply(mvs_scales, function(key) paste(key, '_high', sep="")))
data[mvs_scales_high] <- bin_low_mid_high(data, mvs_scales)

test_scales_high = unlist(lapply(test_scales, function(key) paste(key, '_high', sep="")))
data[test_scales_high] <- bin_low_mid_high(data, test_scales)

# assign treatment groups 1 BL, 2 I, 3 C, 4 A
data$group <- 1
# set high amotivation to group I
data$group[ data$amotivation_high==levels(data$amotivation_high)[3] ] = 2
# set high intrinsic and low amotivation to group A
data$group[ data$intrinsic_high==levels(data$intrinsic_high)[3] ] = 3
data$group[ data$amotivation_high==levels(data$amotivation_high)[1] ] = 3
# set high external, low intrinsic to group C
data$group[ data$external_high==levels(data$external_high)[3] ] = 4
data$group[ data$intrinsic_high==levels(data$intrinsic_high)[1] ] = 4
# re-assign factor levels
data$group <- as.factor(data$group)
levels(data$group) <- c("BL", "I", "A", "C")


# classification tree

#library(OneR)
data$preferred_num = mapvalues(data$preferred, from = levels(data$preferred), to = seq(1, length(levels(data$preferred))))
#frm = as.formula(paste('preferred_num~(', paste(c(test_scales_high,mvs_scales_high), collapse="+"), ')'))
#model <- OneR(frm, data, verbose = TRUE)
#summary(model)

#library(randomForest)
#forest <- randomForest(frm, data = data)
#print(forest) 
#print(importance(forest, type = 2)) 

library(rpart)
library(rpart.plot)
fit <- rpart(pref_A_over_C~., method="class", data=data_raw[ , !(names(data_raw) %in% c('pref_I_over_BL', 'pref_C_over_I', 'pref_A_over_I'))])
#printcp(fit) # display the results 
#plotcp(fit) # visualize cross-validation results 
summary(fit)
rpart.plot(fit, main="Prefers A over C")
fit$variable.importance[1:5]
#  gcos_3_A         gcos_8_I mvs_4_integrated         gcos_2_I         gcos_2_C

fit <- rpart(pref_C_over_I~., method="class", data=data_raw[ , !(names(data_raw) %in% c('pref_A_over_C', 'pref_I_over_BL', 'pref_A_over_I'))])
summary(fit)
rpart.plot(fit, main="Prefers C over I")
fit$variable.importance[1:5]
#  gcos_5_A         gcos_9_A         gcos_1_C mvs_8_identified        gcos_12_A

fit <- rpart(pref_A_over_I~., method="class", data=data_raw[ , !(names(data_raw) %in% c('pref_A_over_C', 'pref_I_over_BL', 'pref_C_over_I'))])
summary(fit)
rpart.plot(fit, main="Prefers A over I")
fit$variable.importance[1:5]
# gcos_11_C gcos_13_I gcos_11_A  gcos_5_C  gcos_8_C


library(FactoMineR)
data_raw_raw_p = data[,c(test_scales)]
data_raw_raw_p$preferred_simple = data$preferred_simple
q = ncol(data_raw_raw_p)
result <- PCA(data_raw_raw_p, ncp=5, quali.sup=q) 
plot(result, choix="ind", habillage=q)
plotellipses(result, q)

data_raw_raw_p = data[,1:24]
data_raw_raw_p$preferred_simple = data$preferred_simple
q = ncol(data_raw_raw_p)
result <- PCA(data_raw_raw_p, ncp=5, quali.sup=q) 
plot(result, choix="ind", habillage=q)
plotellipses(result, q)



 
dim1 = result$var$cor[rev(order(result$var$contrib[,"Dim.1"]))[1:5],]  #mvs_2_intrinsic, mvs_4_integrated, 
dim2 = result$var$cor[rev(order(result$var$contrib[,"Dim.2"]))[1:5],]  #mvs_21_amotivation, mvs_22_amotivation, 
dim3 = result$var$cor[rev(order(result$var$contrib[,"Dim.3"]))[1:5],]  #gcos_13_I, gcos_13_C
dim4 = result$var$cor[rev(order(result$var$contrib[,"Dim.4"]))[1:5],]  #gcos_7_I, gcos_12_I,
dim5 = result$var$cor[rev(order(result$var$contrib[,"Dim.5"]))[1:5],]  #gcos_13_A, -gcos_12_C
# top factors over all dimensions
result$var$cor[rev(order(geometric.mean(t(result$var$contrib))))[1:5],]
result$var$cor[rev(order(apply(result$var$contrib, 1, sum)))[1:10],]


# Try to build regression model with newly selected factors
names = c(rownames(dim1), rownames(dim2), rownames(dim3), rownames(dim4), rownames(dim5))
frm = as.formula(paste('preferred~(', paste(names, collapse="+"), ')'))
library(arm)
fit <- bayesglm(frm, data=data, family="binomial")
summary(fit)


library(nnet) # for multinom
library(car) # for Anova
frm = as.formula(paste('preferred~(', paste(test_scales_high, collapse="+"), ')'))
m = multinom(frm, data=data)
Anova(m, type=3)



library(psych)
f3w <- fa(data_raw_raw, 5, fm="pa")
print(f3w, cut=0.4, digits=3, sort=TRUE)
fa.diagram(f3w)
scores = f3w$scores
scores[] = apply(scores, 2, function(col) col[rev(order(abs(col)))])
scores



frm = as.formula(paste('test_A_high~(', paste(colnames(data_raw_raw), collapse="+"), ')'))
fit <- glm(frm, data=data, family=binomial(), control = list(maxit = 50))
summary(fit)
# test_A_high~mvs_8_identified   1.5270     0.3262   4.681 2.85e-06 ***
# test_C_high~mvs_8_identified   1.8806     0.4201   4.476 7.59e-06 ***
# test_I_high~mvs_8_identified   3.280      0.859   3.819 0.000134 ***
confint(fit)
residuals(fit, type="deviance")

library(arm)
frm = as.formula(paste('test_A_high~(', paste(colnames(data_raw), collapse="*"), ')'))
fit <- bayesglm(frm, data=data, family="binomial")
summary(fit)

cdplot(test_A_high~mvs_8_identified, data=data)  # good
cdplot(test_C_high~mvs_8_identified, data=data)  # good
cdplot(test_I_high~mvs_8_identified, data=data)  # good

cdplot(amotivation_high~mvs_22_amotivation, data=data)
cdplot(test_A_high~gcos_4_I, data=data)
cdplot(test_I_high~gcos_12_I, data=data)
cdplot(introjected_high~mvs_15_introjected, data=data)
       


# Determine number of clusters
wss <- (nrow(d)-1)*sum(apply(d,2,var))
for (i in 2:15) wss[i] <- sum(kmeans(d, centers=i)$withinss)
plot(1:15, wss, type="b", xlab="Number of Clusters", ylab="Within groups sum of squares")

# K-Means Clustering
library(cluster) 
d = data[c(test_scales)]
fit <- kmeans(d, 3)
clusplot(d, fit$cluster, color=TRUE, shade=TRUE, labels=2, lines=0, main="Cluster based on GCOS scores")

d = data_raw_raw
fit <- kmeans(d, 7)
clusplot(d, fit$cluster, color=TRUE, shade=TRUE, labels=2, lines=0, main="Cluster based on raw answers")

d = data[c(mvs_scales)]
fit <- kmeans(d, 5)
clusplot(d, fit$cluster, color=TRUE, shade=TRUE, labels=2, lines=0, main="Cluster based on MVS scores")


library(fpc)
plotcluster(data_raw_raw, fit$cluster)