setwd('/Users/paul/Documents/_Studium/Master Inf/Thesis/code/pilot-study')


test_scales = c('test_A', 'test_C', 'test_I')
mvs_scales = c('intrinsic', 'integrated', 'identified', 'introjected', 'external', 'amotivation')

data = read.csv("data/data.csv", sep=";", header=T)
num_total = nrow(data)
data$pair_order = factor(data$pair_order)
data = data[data$duration>=180,]  # filter out very quick responses
data = data[data$comp_check=='1',]  # filter out failing the check
data = data[data$mvs_check=='1',]  # filter out failing the check
num_eligible = nrow(data)
#View(data)
summary(data)
hist(data$duration)
hist(data$order, breaks=seq(from=-0.5, to=max(data$order)+0.5, by=1))
print(paste('Total:', num_total))
print(paste('Eligible:', num_eligible))
print(paste('Ratio of invalid data:', 1-num_eligible/num_total))

### A couple of ANOVA for "most preferred version"
library(nnet) # for multinom
library(car) # for Anova
m = multinom(preferred ~ duration, data=data)
Anova(m, type=3)
# p>0.1 -> preferred is not correlated with duration

m = multinom(preferred ~ (test_A+test_I+test_C), data=data)
Anova(m, type=3)
# overall, significant effect of all test scales

m = multinom(preferred ~ (intrinsic+integrated+identified+introjected+external+amotivation), data=data)
Anova(m, type=3)
# overall, significant effect of intrinsic and identified scale

m = multinom(preferred ~ (test_A+test_I+test_C+intrinsic+integrated+identified+introjected+external+amotivation), data=data)
Anova(m, type=3)
# most signifcant effects for test_C and intrinsic scale

m = multinom(preferred ~ order, data=data)
Anova(m, type=3)
# p>0.2 no order effect

### Boxplots of score distributions
# MVS distribution
plot.new()
par(mfrow=c(1,2))
LO <- matrix(c(1,1,2), nrow=1, ncol=3, byrow=TRUE)
layout(LO)
mvs_scores = data[rev(mvs_scales)]
par(mar=c(3,3,3,1))
boxplot(mvs_scores, main="Motivation to Volunteer", xlab="Subscale score distribution", yaxt = "n")
axis(side = 2, at = seq(4, 20, 4))
summary(mvs_scores)
# GCOS distribution
par(mar=c(3,3,3,1))
boxplot( data[rev(test_scales)], main="General causality orientation", xlab="Subscale score distribution", yaxt = "n")
axis(side = 2, at = seq(12, 84, 12))


# Pairwise preferences
prefs = read.csv("data/preferences.csv", sep=";", header=T)
prefs = prefs[prefs$duration>=180,]  # filter out very quick responses
prefs = prefs[prefs$comp_check=='1',]  # filter out failing the check
prefs = prefs[prefs$mvs_check=='1',]  # filter out failing the check
# Create new factors to bin test scores into low (1) and high (2) based on mean
test_scales_high = unlist(lapply(test_scales, function(key) paste(key, '_high', sep="")))
prefs[test_scales_high] <- lapply(prefs[test_scales], function(col) factor(as.integer(col > median(col)) + 1))
summary(prefs[test_scales_high])


library(prefmod)
# Loglinear Bradley-Terry Model (LLBT)
objnames = c('AA', 'RR', 'CC', 'A', 'I', 'C', 'BL')
dsgnmat <- llbt.design(prefs, nitems = length(objnames),
                       resptype = "paircomp", ia = TRUE,
                       cat.scovs=c('test', 'test_A_high', 'test_I_high', 'test_C_high'),
                       objnames=objnames)


objnames = c('AA', 'RR', 'CC', 'A', 'I', 'C', 'BL')
formula = as.formula(paste('y ~ (', paste(objnames, collapse='+'), ')'))
res <- gnm(formula, family='poisson', data=dsgnmat)
summary(res)
wmat_o<-llbt.worth(res)
colnames(wmat_o) <- c('overall')

# plot interaction effect with test score (even though it is not statiscally significant)
formula = as.formula(paste('y ~ (', paste(objnames, collapse='+'), ') + (', paste(objnames, collapse='+'), '):(test_A_high+test_I_high+test_C_high)'))
res <- gnm(formula, eliminate = mu, family='poisson', data=dsgnmat)
summary(res)
wmat <- llbt.worth(res)

substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}

# Count number of participants in each bin
coln = colnames(wmat)
factors = sapply(coln, function(c) lapply(strsplit(c, ":"), function(v) cbind(substr(v, 0, nchar(v)-1), substrRight(v, 1))))
nums = lapply(factors, function(item) {
  sum(apply(prefs[c(item[,1])]==c(item[,2]), 1, function(row) all(row)), na.rm=TRUE)
})
nums = c(nums, recursive = TRUE)

par(mar=c(4,4,0,3))
plot.new()
low_high_label = c('-', '+')
low_high_label = c(sprintf('\u2193'), sprintf('\u2191'))
combination_labels = lapply(factors, function(key) paste(apply(key, 1, function(v) paste(substr(v[1], 6, 6), low_high_label[as.integer(v[2])], sep='')), collapse=" "))
colnames(wmat) <- combination_labels
ord = rev(order(unlist(combination_labels)))
ord = seq(1, length(ord), 1)
plot.wmat(cbind(wmat_o, wmat[,ord]), ylim=c(0,0.35), ylab='Worth estimate', main="")
title(main="Version preference by general-causality orientation", outer=TRUE)
title(xlab = "Subscale score groups low/high")
labels <- sapply(nums, function(i) paste("(n=", i, ")", sep=""))
labels = c(c(paste("(n=", nrow(data), ")", sep="")), labels[ord])
axis(side = 1, at = seq(from=1, to=length(labels), by=1), line=1, col = NA, labels = labels, tck = -0.01)

col <- rainbow_hcl(nrow(wmat))
#rect(0.5, -1, 1.5, 1, col= rgb(0,0,1.0,alpha=0.15), lty=0) # highlight overall
rect(1.5, -1, 3.5, 1, col= adjustcolor(col[5], alpha.f = 0.2), lty=0)
#rect(3.5, -1, 5.5, 1, col= adjustcolor(col[2], alpha.f = 0.2), lty=0)
rect(5.5, -1, 7.5, 1, col= adjustcolor(col[4], alpha.f = 0.2), lty=0)

# draw arrows between all combinations
for (n in seq(1, ncol(wmat),2)){
  arrows(n+1, wmat[, ord[n]], n+2, wmat[, ord[n+1]], length=0.15, col=col[match(rownames(wmat), objnames)])
}
