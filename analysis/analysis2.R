setwd('/Users/paul/Documents/_Studium/Master Inf/Thesis/code/pilot-study')

prefs = read.csv("data/preferences.csv", sep=";", header=T)
factor_cols <- c("order", "test", "mvs_check", "comp_check", 'AA_RR', 'AA_CC', 'RR_CC', 'AA_A', 'RR_A', 'CC_A', 'AA_I', 'RR_I', 'CC_I', 'A_I', 'AA_C', 'RR_C', 'CC_C', 'A_C', 'I_C', 'AA_BL', 'RR_BL', 'CC_BL', 'A_BL', 'I_BL', 'C_BL')
mvs_scales = rev(c('intrinsic', 'integrated', 'identified', 'introjected', 'external', 'amotivation'))
test_scales = c('test_A', 'test_C', 'test_I')
prefs[factor_cols] <- lapply(prefs[factor_cols], factor)
prefs = prefs[prefs$duration>=180,]  # filter out very quick responses
prefs = prefs[prefs$comp_check=='1',]  # filter out failing the check
prefs = prefs[prefs$mvs_check=='1',]  # filter out failing the check
head(prefs)
#View(prefs)
summary(prefs)
test_labels = c('A>C>I', 'C>A>I', 'A>I>C', 'I>A>C', 'C>I>A', 'I>C>A')
objnames = c('AA', 'RR', 'CC', 'A', 'I', 'C', 'BL')

# center test scores at mean
prefs[mvs_scales] <- (prefs[mvs_scales]-4)/(20-4) # normalize MVS scales
#prefs[mvs_scales] <- prefs[mvs_scales] - lapply(prefs[mvs_scales], mean)
#prefs[test_scales] <- prefs[test_scales] - lapply(prefs[test_scales], mean)

# center at 0
prefs[mvs_scales] <- prefs[mvs_scales] - 0.5
prefs[test_scales] <- prefs[test_scales] - 0.5

boxplot(prefs[mvs_scales], main="Motivation to Volunteer score distribution", xlab="Subscales")
summary(prefs[mvs_scales])

# test for normal distribution
shapiro.test(prefs$test_A)  # p < 0.5 -> no, probably not normally distribute
shapiro.test(prefs$test_C)  # p > 0.5 -> yes
shapiro.test(prefs$test_I)  # p > 0.5 -> yes
library(MASS)
d <- fitdistr(prefs$test_A, "gamma")
ks.test(prefs$test_A, "pgamma", shape=d$estimate['shape'], rate=d$estimate['rate'])
# seems to fit gamma distribution

library('zoo')

plot.new()
par(mfrow=c(1,3))
ylim=c(0, 40)

print_hist <- function(x, xlab, normal){
  h <- hist(x, breaks=12, xlim=c(-0.5, 0.5), ylim=ylim, main='', xlab=xlab)
  
  xfit <- seq(-0.5, 0.5, length = 80) 
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

print_hist(prefs$test_I, 'Impersonal orientation', TRUE)
print_hist(prefs$test_C, 'Control orientation', TRUE)
print_hist(prefs$test_A, 'Autonomy orientation', TRUE)
  
mtext(paste("Distribution of GCOS results (N=", nrow(prefs), ")", sep = ""), side = 3, line = -3, outer = TRUE)
#title(sub='(Scores normalized and centered at mean)', line=-3, outer=TRUE)


formula = as.formula(paste("(test_A) ~ (", paste(mvs_scales, collapse="+"), ")"))
print(formula)
mod.max <- gnm(formula, data=prefs)
summary(mod.max)  # significant effect of identified subscale

formula = as.formula(paste("(test_I) ~ (", paste(mvs_scales, collapse="+"), ")"))
print(formula)
mod.max <- gnm(formula, data=prefs)
summary(mod.max)  # significant effect of external subscale

formula = as.formula(paste("(test_C) ~ (", paste(mvs_scales, collapse="+"), ")"))
print(formula)
mod.max <- gnm(formula, data=prefs)
summary(mod.max)  # significant effect of intrinsic, external subscales

# Analyze stats
library(prefmod)
# Loglinear Bradley-Terry Model (LLBT)
# why is it poisson?
dsgnmat <- llbt.design(prefs, nitems = length(objnames), resptype = "paircomp", ia = TRUE, cat.scovs=c('test'), num.scovs=c(mvs_scales, c('order', 'test_I', 'test_A', 'test_C')), objnames=objnames)


# maximum model of all interactions
mod.max <- gnm(y ~ (A+C+RR+CC+AA)*(test_A+test_C+test_I+intrinsic+integrated+identified+introjected+external+amotivation), eliminate = mu:CASE, family='poisson', data=dsgnmat)
summary(mod.max)
# interesting effects:
# A:(testA+, testI-, intrinsic+, integrated-, introjected+, amotivation----)
# I: none, dropped
# C:(integrated-, external+, amotivation-)
# RR:(intrinsic+, introjected+, amotivation-)
# CC:(introjected+, external-)
# AA:(intrinsic+, external-)
# BL: none, dropped
# significant versions: A, C, RR, CC, AA
# significant scales: intrinsic, integrated, introjected, amotivation, external (all except identified)

# maximum model of all interactions
mod.max <- gnm(y ~ (A+I+C+RR+CC+AA)*(test_I*test_A*test_C), eliminate = mu:CASE, family='poisson', data=dsgnmat)
summary(mod.max)
# basically everything signficant. maybe model too detailed?

plot(prefs[c('test_I', 'test_A')])
mod.tests <- gnm(test_I~(test_A), eliminate = mu:CASE, family='poisson', data=dsgnmat)
summary(mod.tests)

mod.simple <- gnm(y ~ (A+I+C)*(test), eliminate = mu:CASE, family='poisson', data=dsgnmat)
summary(mod.simple)
anova(mod.max, mod.simple, test="Chisq")
# -> using only the score order instead of absolute test scores is signficantly worse

mod.noInt <- gnm(y ~ (A+I+C)*(test_I+test_A+test_C), eliminate = mu:CASE, family='poisson', data=dsgnmat)
summary(mod.noInt)
anova(mod.max, mod.noInt, test="Chisq")
# -> removing the interactions between the test scores is signficantly worse

# test individual score effects
mod.testA <- gnm(y ~ (A+I+C)*test_A, eliminate = mu:CASE, family='poisson', data=dsgnmat)
summary(mod.testA)
# A signficantly correlated with test_A
mod.testC <- gnm(y ~ (A+I+C)*test_C, eliminate = mu:CASE, family='poisson', data=dsgnmat)
summary(mod.testC)
# C significantly correlated with test_C
mod.testI <- gnm(y ~ (A+I+C)*test_I, eliminate = mu:CASE, family='poisson', data=dsgnmat)
summary(mod.testI)
# I non-signficant, but A (negative) and C (positive) are signficant

mod.AI <- gnm(y ~ (C)*(test_A+test_I+test_C), eliminate = mu:CASE, family='poisson', data=dsgnmat)
summary(mod.AI)


library("Hmisc") 



range = c(-0.5, 0.5)
predict = seq(-0.5, 0.5, 0.05)
show_objnames = c('A', 'AA', 'RR', 'C', 'CC')
plot_prediction <- function(factors, t, xlab) {
  fmla<-as.formula(paste(c("y~(", paste(show_objnames, collapse="+"), ")*(", paste(factors, collapse='+'), ')'), sep='', collapse=''))
  mod <- gnm(fmla, eliminate = mu:CASE, family='poisson', data=dsgnmat)
  est <- parameters(mod)
  cols1 = show_objnames
  cols2 = c(paste(show_objnames, t, sep=':'))
  estmat <- do.call("cbind", lapply(predict, function(x) est[cols1] + est[cols2] * x))
  wmat <- apply(estmat, 2, function(obj) exp(2 * obj)/sum(exp(2 * obj)))
  col <- rainbow_hcl(length(show_objnames))
  plot(range, c(0,0.7), type = "n", xlab='', ylab='Preference estimate')
  for (i in 1:length(cols1)) lines(predict, wmat[i, ], col = col[i])

  curves <- lapply(1:length(cols1), function(i) list(x=predict, y=wmat[i, ]))
  labcurve(curves, cols1, cex=1, offset=0.015, col=col)
  
  title(xlab = xlab, line=2)
  abline(v=mean(prefs[[t]]), col='red', lty=2)
}

# preferences by GCOS score
mod.max <- gnm(y ~ (A+C+RR+CC+AA)*(test_I+test_A+test_C), eliminate = mu:CASE, family='poisson', data=dsgnmat)
summary(mod.max)
plot.new()
LO <- matrix(c(1,2,3,1,2,3,1,2,3,4,5,6), nrow=4, ncol=3, byrow=TRUE)
layout(LO)
par(cex=1)
par(mar=c(0,3,3,1))
par(xaxt='n')
par(mgp=c(2,1,0))
plot_prediction(test_scales, 'test_I', "Impersonal score")
plot_prediction(test_scales, 'test_C', "Control score")
plot_prediction(test_scales, 'test_A', "Autonomy score")
title(main = "Version preferences by causality orientation", line=-2, outer=TRUE)
par(mar=c(5,3,0,1))
par(xaxt='s')
par(mgp=c(2,1,0))
boxplot(prefs$test_I, horizontal=TRUE, ylim=c(-0.5, 0.5), xlab='Impersonal')
boxplot(prefs$test_C, horizontal=TRUE, ylim=c(-0.5, 0.5), xlab='Control')
boxplot(prefs$test_A, horizontal=TRUE, ylim=c(-0.5, 0.5), xlab='Autonomy')
title(sub="Normalized orientation scores", outer=TRUE, line=-2, )

# preferences by MVS score
mod.max <- gnm(y ~ (A+C+RR+CC+AA)*(intrinsic+integrated+identified+introjected+external+amotivation), eliminate = mu:CASE, family='poisson', data=dsgnmat)
summary(mod.max)
plot.new()
par(mfrow=c(2,3))
par(lwd=1.5)
for (i in 1:length(mvs_scales)) plot_prediction(mvs_scales, mvs_scales[i], mvs_scales[i])
title(main = "Version preferences by Motivation to Volunteer score", sub='(All scores normalized and centered at mean)', line=-2, outer=TRUE)
