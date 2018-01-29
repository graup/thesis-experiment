setwd('/Users/paul/Documents/_Studium/Master Inf/Thesis/code/pilot-study')

prefs = read.csv("data/preferences.csv", sep=";", header=T)
head(prefs)
test_labels = c('A>C>I', 'A>I>C', 'I>A>C', 'C>I>A')

# Plot histogram of GCOS results
plot.new()
par(mfrow=NULL)
test_results = xtabs( ~ test, data=prefs)
hist(prefs$test, breaks=seq(from=0.5, to=4.5, by=1), xaxt='n', ylim=c(0,max(test_results) * 1.25), main="Distribution of GCOS test results", xlab='')
axis(side = 1, at = seq(from=1, to=4, by=1), col = NA, labels = test_labels, tck = -0.01)

# Analyze stats
plot.new()
par(mfrow=c(1,2))

library(prefmod)

# Loglinear Bradley-Terry Model (LLBT)
dsgnmat <- llbt.design(prefs, nitems = 4, resptype = "paircomp", ia = TRUE, cat.scovs=c('test'), objnames=c("A", "I", "C", "BL"))
res <- gnm(y ~ A+I+C+BL, family=poisson, data=dsgnmat)
summary(res)
wmat<-llbt.worth(res)
colnames(wmat) <- c('overall')
plot.wmat(wmat, ylim=c(0,0.5))

# plot interaction effect with test score (even though it is not statiscally significant)
res <- gnm(y ~ A+I+C+BL + test:(A+I+C+BL), eliminate = mu:test, family=poisson, data=dsgnmat)
summary(res)
print(test_labels)
wmat <- llbt.worth(res)
colnames(wmat) <- test_labels
plot.wmat(wmat, ylim=c(0,1))
title(xlab = "Order of GCOS results", line=2)

# Alternatively, loglinear Bradley-Terry model for paired comparisons
#res0 <- llbtPC.fit(prefs, nitems=4, formel = ~1, elim=~test, obj.names=c("A", "I", "C", "BL"))
#res1 <- llbtPC.fit(prefs, nitems=4, formel = ~test, elim=~test, obj.names=c("A", "I", "C", "BL"))
# Compare specific with general model
#anova(res0, res1, test='Chisq')
#wmat <- llbt.worth(res1)
#colnames(wmat) <- test_labels
#plot.wmat(wmat)

