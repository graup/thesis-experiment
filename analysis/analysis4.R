setwd('/Users/paul/Documents/_Studium/Master Inf/Thesis/code/pilot-study')

test_scales = c('test_A', 'test_C', 'test_I')
mvs_scales = rev(c('intrinsic', 'integrated', 'identified', 'introjected', 'external', 'amotivation'))
mvs_scales_short = rev(c('intrs', 'ingr', 'iden', 'intrj', 'ext', 'amot'))

# Pairwise preferences
prefs = read.csv("data/preferences.csv", sep=";", header=T)
prefs = prefs[prefs$duration>=180,]  # filter out very quick responses
prefs = prefs[prefs$comp_check=='1',]  # filter out failing the check
prefs = prefs[prefs$mvs_check=='1',]  # filter out failing the check

# Create new factors to bin test scores into low (1) and high (2) based on mean
mvs_scales_high = unlist(lapply(mvs_scales, function(key) paste(key, '_high', sep="")))
prefs[mvs_scales_high] <- lapply(prefs[mvs_scales], function(col) factor(as.integer(col > median(col)) + 1))
summary(prefs[mvs_scales_high])

library(prefmod)
# Loglinear Bradley-Terry Model (LLBT)
objnames = c('AA', 'RR', 'CC', 'A', 'I', 'C', 'BL')
dsgnmat <- llbt.design(prefs, nitems = length(objnames),
                       resptype = "paircomp", ia = TRUE,
                       cat.scovs=mvs_scales_high,
                       objnames=objnames)


# only look at subset of objects. worth estimates will include one item for "other"
#objnames = c('AA', 'RR', 'CC', 'A', 'C', 'BL')

# Model of all motivation scales, without interaction effects between scales
formula = as.formula(paste('y ~ (', paste(objnames, collapse='+'), ') + (', paste(objnames, collapse='+'), '):(', paste(mvs_scales_high, collapse="+"), ')'))
res <- gnm(formula, eliminate = mu, family='poisson', data=dsgnmat)
summary(res)

# Model of all motivation scales, with interaction effects with one other scales (this takes a while to compute)
formula = as.formula(paste('y ~ (', paste(objnames, collapse='+'), ') + (', paste(objnames, collapse='+'), '):(', paste(mvs_scales_high, collapse="+"), '):(', paste(mvs_scales_high, collapse="+"), ')'))
res <- gnm(formula, eliminate = mu, family='poisson', data=dsgnmat)
#summary(res)
# signficant: strongly: intrinsic_high, amotivation_high. weakly: integrated_high
# 
# correlation directions
dirs = sapply(parameters(res), function(val) val > 0)
dir_labels = sapply(dirs, function(b) c('-', '+')[as.integer(b)+1])
p_values = round(summary(res)$coefficients[,4], digits=4)
p_value_label = function(val) {
  if (is.na(val)) return("")
  if (val < 0.001) return("***")
  if (val < 0.01) return("**")
  if (val < 0.05) return("*")
  ""
}
foo = cbind(dir_labels, p_values, lapply(p_values, p_value_label))
# order by effects backwards
s = sapply(strsplit(names(dir_labels), ":"), function(a) c(a, rep('', 5))[1:5])
foo = foo[order(s[5,], s[4,], s[3,], s[2,], s[1,]), ]


# overall prefarance without interactions
formula = as.formula(paste('y ~ (', paste(objnames, collapse='+'), ')'))
res <- gnm(formula, family='poisson', data=dsgnmat)
summary(res)
attr(res$data, 'objnames') <- objnames
wmat_o<-llbt.worth(res)
colnames(wmat_o) <- c('overall')

# model for each subscale for plotting
wmat_for_scale <- function(scale) {
  formula = as.formula(paste('y ~ (', paste(objnames, collapse='+'), ') + (', paste(objnames, collapse='+'), '):(', scale, ')'))
  res <- gnm(formula, eliminate = mu, family='poisson', data=dsgnmat)
  attr(res$data, 'objnames') <- objnames
  llbt.worth(res)
}
wmat = c()
for (scale in mvs_scales_high) {
  wmat = cbind(wmat, wmat_for_scale(scale))
}
# Get a few more wmats of interesting combination effects. two scales both low or both high
#wmat = cbind(wmat, wmat_for_scale('amotivation_high:external_high')[,c(1, 4)])
#wmat = cbind(wmat, wmat_for_scale('external_high:introjected_high')[,c(1, 4)])
#wmat = cbind(wmat, wmat_for_scale('introjected_high:identified_high')[,c(1, 4)])
#wmat = cbind(wmat, wmat_for_scale('identified_high:integrated_high')[,c(1, 4)])
#wmat = cbind(wmat, wmat_for_scale('integrated_high:intrinsic_high')[,c(1, 4)])

# Count number of participants in each bin
substrRight <- function(x, n) substr(x, nchar(x)-n+1, nchar(x))
coln = colnames(wmat)
factors = sapply(coln, function(c) lapply(strsplit(c, ":"), function(v) cbind(substr(v, 0, nchar(v)-1), substrRight(v, 1))))
nums = lapply(factors, function(item) {
  sum(apply(prefs[c(item[,1])]==c(item[,2]), 1, function(row) all(row)), na.rm=TRUE)
})
nums = c(nums, recursive = TRUE)


# Plot worth estimates
par(mar=c(4,4,0,3))
plot.new()
low_high_label = c('-', '+')
low_high_label = c(sprintf('\u2193'), sprintf('\u2191'))
scale_to_label = function(key) mvs_scales_short[match(strsplit(key, '_')[[1]][1], mvs_scales)]
combination_labels = lapply(factors, function(key) paste(apply(key, 1, function(v) paste(scale_to_label(v[1]), low_high_label[as.integer(v[2])], sep='')), collapse=" "))
wmat_ <- wmat
colnames(wmat_) <- combination_labels
#ord = rev(order(unlist(combination_labels)))
ord = seq(1, length(combination_labels), 1)
#ord = rev(ord)
wmat_all = cbind(wmat_o, wmat_[,ord])
#wmat_all = wmat_all[objnames,]
plot.wmat(wmat_all, ylab='Worth estimate', main="") #, ylim=c(0, max(max(wmat_all)*1.01))) 
title(main="Version preference by Motivation to Volunteer", outer=TRUE)
title(xlab = "Subscale score groups low/high")
labels <- sapply(nums, function(i) paste("(n=", i, ")", sep=""))
labels = c(c(paste("(n=", nrow(data), ")", sep="")), labels[ord])
axis(side = 1, at = seq(from=1, to=length(labels), by=1), line=1, col = NA, labels = labels, tck = -0.01)

col <- rainbow_hcl(nrow(wmat_all))
#rect(0.5, -1, 1.5, 1, col= rgb(0,0,1.0,alpha=0.15), lty=0) # highlight overall
rect(1.5, -1, 3.5, 1, col= adjustcolor(col[1], alpha.f = 0.2), lty=0)
rect(5.5, -1, 7.5, 1, col= adjustcolor(col[2], alpha.f = 0.2), lty=0)
rect(9.5, -1, 11.5, 1, col= adjustcolor(col[3], alpha.f = 0.2), lty=0)

# draw arrows between all combinations
for (n in seq(2, ncol(wmat_all), 2)){
  arrows(n, wmat_all[, ord[n-1]+1], n+1, wmat_all[, ord[n]+1], length=0.15, col=col[match(rownames(wmat_all), objnames)])

  comp = colnames(wmat)[n]
  for (ver_i in 1:length(rownames(wmat))) {
    ver = rownames(wmat)[ver_i]
    key = paste(ver, comp, collapse='', sep=':')
    if (!is.na(foo[[key, 2]]) && foo[[key, 2]] < 0.05) {
      # make this arrow red
      print(c(key, foo[[key, 2]]))
      arrows(n, wmat_all[ver_i, ord[n-1]+1], n+1, wmat_all[ver_i, ord[n]+1], length=0.15, lwd=1.3, col="red")
    }
  }
}
# highlight with red arrow all significant changes
# foo[["C:external_high2:introjected_high2", 2]]

# Findings
# scales amotivation and/or external are correlated with an increase preferance for C over A (crossing over)
# scales integrated and/or intrinsic are correlated with an increase preferance for A over C (but only almost crossing over)
# Within the 3 needs,
# scale amotivation is correlated with an increase prefarance of AA over CC
# scale intrinsic is correlated with an increase in prefarance of AA over CC
# BL and I are low value and of insignficant difference across all scales
# 
