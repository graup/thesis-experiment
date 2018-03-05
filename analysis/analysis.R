setwd('/Users/paul/Documents/_Studium/Master Inf/Thesis/code/pilot-study')

data = read.csv("data/data.csv", sep=";", header=T)
data$pair_order = factor(data$pair_order)
data = data[data$duration>=120,]  # filter out very quick responses
#data$test_sum = data$test_A + data$test_C + data$test_I 
View(data)
summary(data$pair_order)
hist(data$duration)
hist(data$order, breaks=seq(from=-0.5, to=max(data$order)+0.5, by=1))

plot(duration ~ preferred, data=data)
plot(preferred ~ test_max, data=data)

library(nnet) # for multinom
library(car) # for Anova
m = multinom(preferred ~ duration, data=data)
Anova(m, type=3)
# p>0.17 -> preferred is not correlated with duration

m = multinom(preferred ~ (test_A+test_I+test_C), data=data)
Anova(m, type=3)
# overall, significant effect of test_A on preference (p<0.05)

m = multinom(preferred ~ test_max, data=data)
Anova(m, type=3)
# p<0.05 -> overall significant effect of test_max on preferred

m = multinom(preferred ~ order * pair_order, data=data)
Anova(m, type=3)
# p<0.1 possible order effect :(
# no effect of pair_order

prefs = read.csv("data/preferences.csv", sep=";", header=T)
prefs = prefs[prefs$duration>=240,] 
head(prefs)
test_labels = c('I>A>C', 'A>C>I', 'C>I>A', 'A>I>C', 'C>A>I', 'I>C>A')

# Plot histogram of GCOS results
plot.new()
par(mfrow=NULL)
test_results = xtabs( ~ test, data=prefs)
hist(prefs$test, breaks=seq(from=0.5, to=max(prefs$test)+0.5, by=1), xaxt='n', ylim=c(0,max(test_results) * 1.25), main="Distribution of GCOS test results", xlab='')
axis(side = 1, at = seq(from=1, to=max(prefs$test), by=1), col = NA, labels = test_labels, tck = -0.01)


# Analyze stats
plot.new()
par(mfrow=c(1,1))

library(prefmod)

# Loglinear Bradley-Terry Model (LLBT)
dsgnmat <- llbt.design(prefs, nitems = 4, resptype = "paircomp", ia = TRUE, cat.scovs=c('test'), objnames=c("A", "I", "C", "BL"))
res <- gnm(y ~ (A+I+C+BL), family='poisson', data=dsgnmat)
summary(res)
wmat_o<-llbt.worth(res)
colnames(wmat_o) <- c('overall')
#plot.wmat(wmat, ylim=c(0,0.65))

# plot interaction effect with test score (even though it is not statiscally significant)
res <- gnm(y ~ (A+I+C+BL) + (A+I+C+BL):test, eliminate = mu, family='poisson', data=dsgnmat)
summary(res)
print(test_labels)

wmat <- llbt.worth(res)
ord = rev(order(test_results))
wmat <- wmat[,ord]
colnames(wmat) <- test_labels[ord]
plot.wmat(cbind(wmat_o, wmat), ylim=c(0,0.65), main="")
title(xlab = "Order of GCOS results", line=0)
#labels <- lapply(seq_along(test_results), function(i) paste(test_labels[i]," (n=", test_results[i], ")", sep=""))
labels <- lapply(ord, function(i) paste("(n=", test_results[i], ")", sep=""))
labels = c(c(paste("(n=", sum(test_results), ")", sep="")), labels)
axis(side = 1, at = seq(from=1, to=max(1+prefs$test), by=1), line=1, col = NA, labels = labels, tck = -0.01)


