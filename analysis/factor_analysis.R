setwd('/Users/paul/Documents/_Studium/Master Inf/Thesis/code/pilot-study')

test_scales = c('test_A', 'test_C', 'test_I')
mvs_scales = c('intrinsic', 'integrated', 'identified', 'introjected', 'external', 'amotivation')

data = read.csv("data/raw_answers.csv", sep=";", header=T)
num_total = nrow(data)

factor_cols <- c("mvs_check", "comp_check", "gcos_check", "preferred")
data[factor_cols] <- lapply(data[factor_cols], factor)
raw_cols = setdiff(24:89, c(48, 58, 62, 72, 76, 86))
raw_cols_names = colnames(data[,raw_cols])
raw_mvs_cols_names = colnames(data[,24:47])
data[,raw_cols] <- lapply(data[,raw_cols], factor)

data = data[data$comp_check=='1',]  # filter out failing the check
data = data[data$mvs_check=='1',]  # filter out failing the check
data = data[ , !(names(data) %in% c("comp_check", "mvs_check"))]  # we don't need these columns anymore

data_raw = data[ , !(names(data) %in% c(test_scales, mvs_scales, 'preferred', 'preferred_simple'))]  # drop these columns
data_raw = data_raw[ , 22:ncol(data_raw)]
data_raw = data_raw[ , !(names(data_raw) %in% c('gcos_0_check', 'gcos_0_check.1', 'gcos_0_check.2', 'gcos_10_check', 'gcos_10_check.1', 'gcos_10_check.2'))]  # drop these columns

data_raw_raw = data_raw[ , !(names(data_raw) %in% c('pref_A_C', 'pref_C_BL', 'pref_A_BL'))]

data$preferred_simple_num = mapvalues(data$preferred_simple, from = levels(data$preferred_simple), to = seq(1, length(levels(data$preferred_simple))))

library(plyr)
bin_low_mid_high = function(data, scales) {
  lapply(data[scales], function(col) {
    # cut into <25%, 25-75%, 75%<
    c = cut(col,  breaks=c(0, quantile(col, probs=c(0.25, 0.75), na.rm=TRUE), max(col)))
    # map to integer factors
    mapvalues(c, from = levels(c), to = seq(1, 3))
  })
}


bin_low_high = function(data, scales) {
  lapply(data[scales], function(col) {
    c = cut(col,  breaks=c(0, quantile(col, probs=c(0.75), na.rm=TRUE), max(col)))
    mapvalues(c, from = levels(c), to = seq(1, 2))
  })
}


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

library(partykit)
data_raw$preferred_simple = data$preferred_simple
fit <- ctree(pref_A_C ~ ., data=data_raw[ , !(names(data_raw) %in% c('preferred_simple', 'pref_A_BL', 'pref_C_BL', 'preferred_simple_num'))],
             control = ctree_control(minsplit = 1, minbucket = 8, maxsurrogate=100, mtry=20, splittry=100, mincriterion=0.01))
plot(fit, main="Conditional Inference Tree for Preferance of A over C")

fit <- glmtree(preferred_simple ~ .,  family = "binomial", data=data_raw[ , !(names(data_raw) %in% c('pref_A_C', 'pref_A_BL', 'pref_C_BL', 'preferred_simple_num'))])
plot(fit)
print(fit)

fit <- glmtree(pref_A_C ~ .,  family = "binomial", data=data_raw[ , !(names(data_raw) %in% c('preferred_simple', 'pref_A_BL', 'pref_C_BL', 'preferred_simple_num'))])
plot(fit)
print(fit)

library(rpart)
library(rpart.plot)
fit <- rpart(pref_A_C~., method="class", data=data_raw[ , !(names(data_raw) %in% c('pref_A_BL', 'pref_C_BL', 'preferred_simple', 'preferred_simple_num'))],
             control = rpart.control(minsplit=10, cp = 0.001, xval=20))
printcp(fit)
plotcp(fit) # visualize cross-validation results 
summary(fit)
rpart.plot(fit, main="Prefers A over C")
fit$variable.importance[1:5]
#  gcos_4_I gcos_11_I

fit <- rpart(pref_A_BL~., method="class", data=data_raw[ , !(names(data_raw) %in% c('pref_A_C', 'pref_C_BL', 'preferred_simple_num'))])
printcp(fit)
summary(fit)
rpart.plot(fit, main="Prefers C over I")
fit$variable.importance[1:5]
#  mvs_20_amotivation           gcos_4_I          gcos_13_C    gcos_11_A

fit <- rpart(pref_C_BL~., method="class", data=data_raw[ , !(names(data_raw) %in% c('pref_A_C', 'pref_A_BL', 'preferred_simple_num'))])
printcp(fit)
summary(fit)
rpart.plot(fit, main="Prefers A over I")
fit$variable.importance[1:5]
# gcos_6_A     mvs_2_intrinsic   gcos_4_C


library(FactoMineR)
data_raw_raw_p = data[,c(test_scales)]
data_raw_raw_p$preferred_simple = data$preferred_simple
q = ncol(data_raw_raw_p)
result <- PCA(data_raw_raw_p, ncp=5, quali.sup=q) 
plot(result, choix="ind", habillage=q)
plotellipses(result, q)

data_raw_raw_p = data[,22:87]  # 24, 42
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

names = colnames(data[,22:86])
# 1:21 prefs
# 22:46 mvs
# 47:89 gcos
prefs = data[,1:87]  
mvs_scales_high = unlist(lapply(mvs_scales, function(key) paste(key, '_high', sep="")))
prefs[mvs_scales_high] <- bin_low_mid_high(data, mvs_scales)

test_scales_high = unlist(lapply(test_scales, function(key) paste(key, '_high', sep="")))
prefs[test_scales_high] <- bin_low_mid_high(data, test_scales)


library(prefmod)
# Rerunning same model that produced Figure 3/4
objnames = c('AA', 'RR', 'CC', 'A', 'I', 'C', 'BL')
dsgnmat <- llbt.design(prefs, nitems = length(objnames),
                       resptype = "paircomp", ia = TRUE,
                       num.scovs=names,
                       cat.scovs=c(test_scales_high, mvs_scales_high),
                       objnames=objnames)
objnames = c('A', 'C')

# Compare A and C regarding GCOS and MVS test scores
formula = as.formula(paste('y ~ (', paste(objnames, collapse='+'), ') + (', paste(objnames, collapse='+'), '):(', paste(c(test_scales_high, mvs_scales_high), collapse="+"),')'))
# formula = y ~ (A + C) + (A + C):(test_A_high + test_C_high + test_I_high + intrinsic_high + integrated_high + identified_high + introjected_high + external_high + amotivation_high)
res <- gnm(formula, eliminate = mu, family='poisson', data=dsgnmat)
s <- summary(res)
sc = as.data.frame(s$coefficients)
sc[with(sc, order(-abs(Estimate))), ]
# strongest effects:
# C:test_C_high3      +0.8 p<0.001
# C:intrinsic_high3   -0.6 p<0.01
# A:amotivation_high3 -0.4 p<0.01

# Now let's figure out which of these scales' items we can use
# amotivation: mvs_20-23_amotivation
# intrinsic: mvs_0-3_intrinsic
# test_C: gcos_1-13_C
names = c(
  sapply(seq(20,23), function(n) paste('mvs_', n, '_amotivation', sep="")),
  sapply(seq(0,3), function(n) paste('mvs_', n, '_intrinsic', sep="")),
  sapply(setdiff(seq(0,13), c(0, 10)), function(n) paste('gcos_', n, '_C', sep=""))
)
formula = as.formula(paste('y ~ (', paste(objnames, collapse='+'), ') + (', paste(objnames, collapse='+'), '):(', paste(names, collapse="+"),')'))
# formula = y ~ (A + C) + (A + C):(mvs_20_amotivation + mvs_21_amotivation + mvs_22_amotivation + mvs_23_amotivation + mvs_0_intrinsic + mvs_1_intrinsic + mvs_2_intrinsic + mvs_3_intrinsic + gcos_1_C + gcos_2_C + gcos_3_C + gcos_4_C + gcos_5_C + gcos_6_C + gcos_7_C + gcos_8_C + gcos_9_C + gcos_11_C + gcos_12_C + gcos_13_C)
res <- gnm(formula, eliminate = mu, family='poisson', data=dsgnmat)
s <- summary(res)
sc = as.data.frame(s$coefficients)
sc[with(sc, order(-abs(Estimate))), ]
# Strongest effects
# C:mvs_22_amotivation  -0.27  p<0.01
# C:mvs_1_intrinsic     -0.24  p<0.01
# A:mvs_20_amotivation  +0.19  p<0.05
# A:mvs_0_intrinsic     +0.17  p<0.05
# A:mvs_22_amotivation  -0.17  p<0.01
# C:mvs_20_amotivation  +0.16  p<0.05
# C:gcos_11_C           +0.12  p<0.01
# C:gcos_2_C            +0.12  p<0.05
# A:gcos_2_C            -0.09  p<0.1


# Step3: Make a decision tree with these items to check the accuracy
require(caTools)
library(caret)

for (minsplit in c(10)) {  #seq(5,13)
  total_k1 = 0
  total_k2 = 0
  n_repeat = 25
  set.seed(1000)
  for (r in 1:n_repeat) {
    d <- data
    sample = sample.split(d$pref_A_C, SplitRatio = .6)
    train = subset(d, sample == TRUE)
    test  = subset(d, sample == FALSE)
    
    #frm = pref_A_C~(mvs_22_amotivation+mvs_1_intrinsic+mvs_20_amotivation+mvs_0_intrinsic+gcos_11_C+gcos_2_C)
    #frm = pref_A_C~.
    frm = as.formula(paste('pref_A_C ~ (', paste(c(test_scales, mvs_scales), collapse="+"),')'))
    fit <- rpart(frm, method="class", data=train[ , !(names(train) %in% c('pref_C_BL', 'pref_A_BL'))],
                 control = rpart.control(minsplit=minsplit))
    #printcp(fit)
    #plotcp(fit)
    #summary(fit)
    #rpart.plot(fit, main="Prefers A over C", extra=103)
    
    calc_accuracy = function(fit, data, column) {
      p <- predict(fit, data, type="class")  # 
      confusionMatrix(p, data[[column]], positive="True") 
    }
    a1 <- calc_accuracy(fit, train, 'pref_A_C') # Accuracy 75%, Sensitivity 46%, Specificity 89%
    a2 <- calc_accuracy(fit, test, 'pref_A_C') # Accuracy 57%, Sensitivity 46%, Specificity 62%
  
    total_k1 = total_k1 + a1$overall[['Kappa']] / n_repeat
    total_k2 = total_k2 + a2$overall[['Kappa']] / n_repeat
  }
  print(minsplit)
  print(paste("kappa 1", total_k1))
  print(paste("kappa 2", total_k2))
}

library(rpartScore)
data$pref_A_C.num = as.numeric(mapvalues(data$pref_A_C, from = levels(data$pref_A_C), to = seq(1, length(levels(data$pref_A_C)))))
fit <- rpartScore(frm, data=data, control = rpart.control(minsplit=5))



library (partykit)
names = c(
  sapply(seq(20,23), function(n) paste('mvs_', n, '_amotivation', sep="")),
  sapply(seq(0,3), function(n) paste('mvs_', n, '_intrinsic', sep="")),
  sapply(setdiff(seq(0,13), c(0, 10)), function(n) paste('gcos_', n, '_C', sep=""))
)
frm = as.formula(paste('pref_A_C ~ (', paste(c(test_scales, mvs_scales), collapse="+"),')'))
frm = as.formula(paste('pref_A_C ~ (', paste(raw_mvs_cols_names, collapse="+"),')'))
fit <- ctree(frm, data = data,
             control = ctree_control(minsplit = 1, minbucket = 5, mincriterion=0.01))
plot(fit, main="Conditional Inference Tree for Preferance of A over C")
confusionMatrix(predict(fit), data$pref_A_C, positive="True") 


set.seed(20180329)
n_repeat = 50
results_train = list()
results_test = list()
for (r in 1:n_repeat) {
  d <- data
  sample = sample.split(d$pref_A_C, SplitRatio = .75)
  train = subset(d, sample == TRUE)
  test  = subset(d, sample == FALSE)
  
  frm = as.formula(paste('pref_A_C ~ (', paste(raw_mvs_cols_names, collapse="+"),')'))
  fit <- ctree(frm, data = train,
               control = ctree_control(minsplit = 1, minbucket = 5, mincriterion=0.001))
  
  calc_accuracy = function(fit, data, column) {
    p <- predict(fit) 
    confusionMatrix(p, data[[column]], positive="True") 
  }
  a1 <- confusionMatrix(predict(fit), train$pref_A_C, positive="True") 
  a2 <- confusionMatrix(predict(fit, newdata=test, type="response"), test$pref_A_C, positive="True")
  results_train[[r]] <- c(a1$byClass, a1$overall)
  results_test[[r]]  <- c(a2$byClass, a2$overall)
}
results_train = do.call(cbind, results_train)
results_test = do.call(cbind, results_test)
print(rowMeans(results_train))
print(rowMeans(results_test))
plot(fit, main="Conditional Inference Tree for Preferance of A over C")




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