setwd('/Users/paul/Documents/_Studium/Master Inf/Thesis/code/pilot-study')

prefs = read.csv("data/preferences.csv", sep=";", header=T)
#View(prefs)
test_labels = c('A>C>I', 'A>I>C', 'I>A>C', 'C>I>A')

par(mfrow=c(1,2))

library(prefmod)

dsgnmat <- llbt.design(prefs, nitems = 4, resptype = "paircomp", ia = TRUE, cat.scovs=c('test'),objnames=c("A", "I", "C", "BL"))
res<-gnm(y ~ A+I+C+BL, family=poisson, data=dsgnmat)
summary(res)
wmat<-llbt.worth(res)
colnames(wmat) <- c('overall')
plot.wmat(wmat)

res<-gnm(y ~ (A+I+C+BL)*test, family=poisson, data=dsgnmat)
summary(res)
print(test_labels)
wmat<-llbt.worth(res)
colnames(wmat) <- test_labels
plot.wmat(wmat)

# Alternatively, loglinear Bradley-Terry model for paired comparisons
res0 <- llbtPC.fit(prefs, nitems=4, formel = ~1, elim=~test, obj.names=c("A", "I", "C", "BL"))
res1 <- llbtPC.fit(prefs, nitems=4, formel = ~test, elim=~test, obj.names=c("A", "I", "C", "BL"))
anova(res0, res1, test='Chisq')
wmat <- llbt.worth(res1)
colnames(wmat) <- test_labels
plot.wmat(wmat)

