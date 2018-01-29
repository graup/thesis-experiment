setwd('/Users/paul/Documents/_Studium/Master Inf/Thesis/code/pilot-study')

prefs = read.csv("data/preferences.csv", sep=";", header=T)
head(prefs)
test_labels = c('A>C>I', 'A>I>C', 'I>A>C', 'C>I>A')
objnames = c('A', 'I', 'C', 'BL')

plot.new()
par(mfrow=c(1,3))
ylim=c(0, 10)
hist(prefs$test_A, breaks=6, xlim=c(12, 84), ylim=ylim, main='', xlab='Autonomy orientation')
hist(prefs$test_C, breaks=6, xlim=c(12, 84), ylim=ylim, main='', xlab='Control orientation')
hist(prefs$test_I, breaks=6, xlim=c(12, 84), ylim=ylim, main='', xlab='Impersonal orientation')
mtext("Distribution of GCOS results (N=17)", side = 3, line = -3, outer = TRUE)


# Analyze stats
plot.new()
par(mfrow=c(1,3))

library(prefmod)

# check overall significance
res <- gnm(y ~ (A+I+C+BL), eliminate = mu:CASE, family=poisson, data=dsgnmat)
summary(res)


# check significance of interactions
res <- gnm(y ~ (A+I+C+BL)*(test_I+test_A+test_C), eliminate = mu:CASE, family=poisson, data=dsgnmat)
summary(res)


# preferences x test_I
res <- gnm(y ~ (A+I+C+BL)*(test_I), eliminate = mu:CASE, family=poisson, data=dsgnmat)
est <- parameters(res)
estmat <- do.call("cbind", lapply(12:84,
          function(x) est[1:4] + est[6:9] * x))
wmat <- apply(estmat, 2, function(obj) exp(2 * obj)/sum(exp(2 * obj)))
col <- rainbow_hcl(4)
plot(c(0, 90), c(0,1), type = "n", ylab='Preference estimate')
for (i in 1:4) lines(12:84, wmat[i, ], col = col[i])
text(rep(10, 5), wmat[, 1], objnames)
title(xlab = "Impersonal score", line=2)

# preferences x test_A
res <- gnm(y ~ (A+I+C+BL)*(test_A), eliminate = mu:CASE, family=poisson, data=dsgnmat)
est <- parameters(res)
estmat <- do.call("cbind", lapply(12:84,
                                  function(x) est[1:4] + est[6:9] * x))
wmat <- apply(estmat, 2, function(obj) exp(2 * obj)/sum(exp(2 * obj)))
col <- rainbow_hcl(4)
plot(c(0, 90), c(0,1), type = "n", ylab='Preference estimate')
for (i in 1:4) lines(12:84, wmat[i, ], col = col[i])
text(rep(10, 5), wmat[, 1], objnames)
title(xlab = "Autonomy score", line=2)

# preferences x test_C
res <- gnm(y ~ (A+I+C+BL)*(test_C), eliminate = mu:CASE, family=poisson, data=dsgnmat)
est <- parameters(res)
estmat <- do.call("cbind", lapply(12:84,
                                  function(x) est[1:4] + est[6:9] * x))
wmat <- apply(estmat, 2, function(obj) exp(2 * obj)/sum(exp(2 * obj)))
col <- rainbow_hcl(4)
plot(c(0, 90), c(0,1), type = "n", ylab='Preference estimate')
for (i in 1:4) lines(12:84, wmat[i, ], col = col[i])
text(rep(10, 5), wmat[, 1], objnames)
title(xlab = "Control score", line=2)

title(main = "Preferences by causality orientation", line=-2, outer=TRUE)

# Alternatively, loglinear Bradley-Terry model for paired comparisons
#res0 <- llbtPC.fit(prefs, nitems=4, formel = ~1, elim=~test, obj.names=c("A", "I", "C", "BL"))
#res1 <- llbtPC.fit(prefs, nitems=4, formel = ~test, elim=~test, obj.names=c("A", "I", "C", "BL"))
# Compare specific with general model
#anova(res0, res1, test='Chisq')
#wmat <- llbt.worth(res1)
#colnames(wmat) <- test_labels
#plot.wmat(wmat)

