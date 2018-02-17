setwd('/Users/paul/Documents/_Studium/Master Inf/Thesis/code/pilot-study')

prefs = read.csv("data/preferences.csv", sep=";", header=T)
prefs$order = factor(prefs$order)
prefs = prefs[prefs$duration>=120,]  # filter out very quick responses
head(prefs)
View(prefs)
count(prefs)
summary(prefs)
test_labels = c('I>A>C', 'A>C>I', 'C>I>A', 'A>I>C', 'C>A>I', 'I>C>A')
objnames = c('A', 'I', 'C', 'BL')

# center test scores at mean
#prefs$test_A = prefs$test_A - mean(prefs$test_A)
#prefs$test_I = prefs$test_I - mean(prefs$test_I)
#prefs$test_C = prefs$test_C - mean(prefs$test_C)

# test for normal distribution
shapiro.test(prefs$test_A)  # no
shapiro.test(prefs$test_C)  # yes
shapiro.test(prefs$test_I)  # yes
d <- fitdistr(prefs$test_A, "gamma")
ks.test(prefs$test_A, "pgamma", shape=d$estimate['shape'], rate=d$estimate['rate'])
# seems to fit gamma distribution

library('zoo')

plot.new()
par(mfrow=c(1,3))
ylim=c(0, 40)

print_hist <- function(x, xlab, normal){
  h <- hist(x, breaks=12, xlim=c(0, 1), ylim=ylim, main='', xlab=xlab)
  
  xfit <- seq(0, 1, length = 40) 
  if (normal) {
    # normal distribution
    yfit <- dnorm(xfit, mean = mean(x), sd = sd(x)) 
    yfit <- yfit * diff(h$mids[1:2]) * length(x) 
    lines(xfit, yfit, col="blue", lwd=1)
  } else {
    # gamma distribution
    d <- fitdistr(1-x, "gamma")
    #shape = mean(1-x)^2/var(1-x)
    #scale = var(1-x)/mean(1-x)
    
    yfit <-  dgamma(xfit, shape=d$estimate['shape'], rate=d$estimate['rate'])
    yfit <- yfit * diff(h$mids[1:2]) * length(x) 
    lines(xfit, rev(yfit), col="blue", lwd=1)
  }
  

  #g_counts <- dgamma(h$breaks, shape=mean(1-x)^2/var(1-x), scale=var(1-x)/mean(1-x))
  #g_counts <- rev(g_counts * diff(h$mids[1:2]) * length(x))
  #print(ks.test(h$counts, g_counts, exact=FALSE))
  # gamma distribution seems to fit
}

print_hist(prefs$test_A, 'Autonomy orientation', FALSE)
print_hist(prefs$test_C, 'Control orientation', TRUE)
print_hist(prefs$test_I, 'Impersonal orientation', TRUE)
  
mtext("Distribution of GCOS results (N=124)", side = 3, line = -3, outer = TRUE)
#title(sub='(Scores normalized and centered at mean)', line=-3, outer=TRUE)


# Analyze stats
library(prefmod)
# Loglinear Bradley-Terry Model (LLBT)
dsgnmat <- llbt.design(prefs, nitems = 4, resptype = "paircomp", ia = TRUE, cat.scovs=c('order'), num.scovs=c('test_I', 'test_A', 'test_C'), objnames=c("A", "I", "C", "BL"))

# maximum model of all interactions
# BL was dropped. It ranked consistently low and had non-signficant interaction with other factors
mod.max <- gnm(y ~ (A+I+C)*(test_I*test_A*test_C) + (A+I+C):order, eliminate = mu:CASE, family='poisson', data=dsgnmat)
summary(mod.max)
# order effect is non-significant

mod.simple <- gnm(y ~ (A+I+C)*(test), eliminate = mu:CASE, family=poisson, data=dsgnmat)
anova(mod.max, mod.simple, test="Chisq")
# -> using only the score order instead of absolute test scores is signficantly worse

mod.noInt <- gnm(y ~ (A+I+C)*(test_I+test_A+test_C), eliminate = mu:CASE, family=poisson, data=dsgnmat)
summary(mod.noInt)
anova(mod.max, mod.noInt, test="Chisq")
# -> removing the interactions between the test scores is signficantly worse

# test individual score effects
mod.testA <- gnm(y ~ (A+I+C)*test_A, eliminate = mu:CASE, family=poisson, data=dsgnmat)
summary(mod.testA)
# both A and I seem to be (positively) correlated to test_A, but why is C non-signficantly negatively correlated??
mod.testC <- gnm(y ~ (A+I+C)*test_C, eliminate = mu:CASE, family=poisson, data=dsgnmat)
summary(mod.testC)
# no signficant correlation
mod.testI <- gnm(y ~ (A+I+C)*test_I, eliminate = mu:CASE, family=poisson, data=dsgnmat)
summary(mod.testI)
# both A and I seem to be (negatively) correlated to test_I, but why is C non-signficantly positively correlated??



# plot
plot.new()
par(mfrow=c(1,3))
#predict = seq(-0.5, 0.5, 0.05)
range = c(0, 1)
predict = seq(0, 1, 0.05)
plot_prediction <- function(t, xlab) {
  fmla<-as.formula(paste(c("y~(A+I+C)*test", t), sep='', collapse='_'))
  mod <- gnm(fmla, eliminate = mu:CASE, family='poisson', data=dsgnmat)
  est <- parameters(mod)
  cols1 = c('A', 'C', 'I')
  cols2 = c(paste(c('A:test_', t), collapse=""), paste(c('C:test_', t), collapse=""), paste(c('I:test_', t), collapse=""))
  estmat <- do.call("cbind", lapply(predict,
                                    function(x) est[cols1] + est[cols2] * x))
  wmat <- apply(estmat, 2, function(obj) exp(2 * obj)/sum(exp(2 * obj)))
  col <- rainbow_hcl(3)
  plot(c(0, 1), c(0,1), type = "n", xlab='', ylab='Preference estimate')
  for (i in 1:3) lines(predict, wmat[i, ], col = col[i])
  text(rep(0.05, 1), wmat[, 1], cols1)
  title(xlab = xlab, line=2)
}

plot_prediction('I', "Impersonal score")
plot_prediction('A', "Autonomy score")
plot_prediction('C', "Control score")
title(main = "Preferences by causality orientation", sub='(Scores normalized and centered at mean)', line=-2, outer=TRUE)
