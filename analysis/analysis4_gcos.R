setwd('/Users/paul/Documents/_Studium/Master Inf/Thesis/code/pilot-study')

test_scales = rev(c('test_A', 'test_C', 'test_I'))
test_scales_short = rev(c('A', 'C', 'I'))
mvs_scales = rev(c('intrinsic', 'integrated', 'identified', 'introjected', 'external', 'amotivation'))
mvs_scales_short = rev(c('intrs', 'ingr', 'iden', 'intrj', 'ext', 'amot'))

mvs_scales = rev(c('intrinsic', 'identified', 'external', 'amotivation'))
mvs_scales_short = rev(c('intrs', 'iden', 'ext', 'amot'))

measure = 'gcos'

if (measure == 'mvs') {
  scales = mvs_scales
  scales_short = mvs_scales_short
  fname = 'preferances-by-mvs'
  main_title = "Version Preference by Motivation to Volunteer"
}
if (measure == 'gcos') {
  scales = test_scales
  scales_short = test_scales_short
  fname = 'preferances-by-gcos'
  main_title = "Version Preference by General-causality Orientation"
}
if (measure == 'volunteer') {
  fname = 'preferances-by-volunteering'
  main_title = "Version Preference by Volunteering Frequency"
}

draw_arrows = TRUE

# Pairwise preferences
prefs = read.csv("data/preferences.csv", sep=";", header=T)
prefs = prefs[prefs$duration>=180,]  # filter out very quick responses
prefs = prefs[prefs$comp_check=='1',]  # filter out failing the check
prefs = prefs[prefs$mvs_check=='1',]  # filter out failing the check
factor_cols <- c("volunteering_freq")
prefs[factor_cols] <- lapply(prefs[factor_cols], factor)

# Create new factors to bin test scores into low (1) and high (2) based on mean
scales_high = unlist(lapply(scales, function(key) paste(key, '_high', sep="")))

method = 'quartiles'
if (method == 'median') {
  prefs[scales_high] <- lapply(prefs[scales], function(col) {
    factor(as.integer(col > median(col)) + 1)
  })
}
if (method == 'quartiles') {
  prefs[scales_high] <- lapply(prefs[scales], function(col) {
    # cut into <25%, 25-75%, 75%<
    c = cut(col,  breaks=c(0, quantile(col, probs=c(0.25, 0.75), na.rm=TRUE), max(col)))
    # map to integer factors
    mapvalues(c, from = levels(c), to = seq(1,3))
  })
}
summary(prefs[scales_high])

if (measure == 'volunteer') {
  scales_high = c('volunteering_freq')
  scales = c('volunteering_freq')
  scales_short = c('')
}

library(prefmod)
# Loglinear Bradley-Terry Model (LLBT)
objnames = c('nA', 'nR', 'nC', 'A', 'I', 'C', 'bl')
dsgnmat <- llbt.design(prefs, nitems = length(objnames),
                       resptype = "paircomp", ia = TRUE,
                       cat.scovs=scales_high,
                       objnames=objnames)


# only look at subset of objects. worth estimates will include one item for "other"
#objnames = c('C', 'A', 'AA', 'RR', 'CC', 'I', 'BL')

# Model of all motivation scales, without interaction effects between scales
##formula = as.formula(paste('y ~ (', paste(objnames, collapse='+'), ') + (', paste(objnames, collapse='+'), '):(', paste(scales_high, collapse="+"), '):(', paste(scales_high, collapse="+"), ')'))
formula = as.formula(paste('y ~ (', paste(objnames, collapse='+'), ') + (', paste(objnames, collapse='+'), '):(', paste(scales_high, collapse="+"),')'))
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
  w = llbt.worth(res)
  if (method == 'quartiles' && measure != 'volunteer') return(w[, c(1,3)])
  return(w)
}
wmat = c()
for (scale in scales_high) {
  wmat = cbind(wmat, wmat_for_scale(scale))
}
# Get a few more wmats of interesting combination effects. two scales both low or both high
#wmat = cbind(wmat, wmat_for_scale('test_I_high:test_C_high')[,c(1, 4)])
#wmat = cbind(wmat, wmat_for_scale('test_C_high:test_A_high')[,c(1, 4)])
#wmat = cbind(wmat, wmat_for_scale('test_I_high:test_A_high')[,c(1, 4)])
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
# setup
RESO <- 300  # Resolution
PS <- 12  # Pointsize
LO <- matrix(c(1), nrow=1, ncol=1, byrow=TRUE)
WIDTHS <- c(10) #widths of each figure in layout (i.e. column widths) in inch
HEIGHTS <- c(5)  #heights of each figure in layout (i.e. row heights) in inch
OMA <- c(0,0,0,0)  #Outer margins c(bottom, left, top, right)
HEIGHT <- sum(HEIGHTS) + OMA[1]*PS*1/72 + OMA[3]*PS*1/72
WIDTH <- sum(WIDTHS) + OMA[2]*PS*1/72 + OMA[4]*PS*1/72
png(paste("/Users/paul/Documents/_Studium/Master Inf/Thesis/study results/mturk2/", fname, ".png", sep=""), width=WIDTH, height=HEIGHT, units="in", res=RESO)
par(oma=OMA, ps=PS) #settings before layout
layout(LO, heights=HEIGHTS, widths=WIDTHS)
par(cex=1)

par(mar=c(4,4,0,3), omi=c(0.2,0.2,0.5,0.2))
low_high_label = c('-', '+')
low_high_label = c(sprintf('\u2193'), sprintf('\u2191'), sprintf('\u2191'))
if (method == 'quartiles') {
  low_high_label = c(sprintf('\u2193'), ' ', sprintf('\u2191')) 
}
if (measure == 'volunteer') {
  low_high_label = c('Never', '< 1/week', '1/week or more')
}
scale_to_label = function(key) scales_short[match(strsplit(key, '_high')[[1]][1], scales)]
combination_labels = lapply(factors, function(key) paste(apply(key, 1, function(v) paste(scale_to_label(v[1]), low_high_label[as.integer(v[2])], sep='')), collapse=" "))
wmat_ <- wmat
colnames(wmat_) <- combination_labels
#ord = rev(order(unlist(combination_labels)))
ord = seq(1, length(combination_labels), 1)
#ord = rev(ord)
wmat_all = cbind(wmat_o, wmat_[,ord])
#wmat_all = wmat_all[objnames,]
plot.wmat(wmat_all, ylab='Worth estimate', main="") #, ylim=c(0, max(max(wmat_all)*1.01))) 
title(main=main_title, outer=TRUE)
title(xlab = "Subscale score groups")
labels <- sapply(nums, function(i) paste("(n=", i, ")", sep=""))
labels = c(c(paste("(n=", nrow(data), ")", sep="")), labels[ord])
axis(side = 1, at = seq(from=1, to=length(labels), by=1), line=1, col = NA, labels = labels, tck = -0.01)

col <- rainbow_hcl(nrow(wmat_all))
#rect(0.5, -1, 1.5, 1, col= rgb(0,0,1.0,alpha=0.15), lty=0) # highlight overall
factor_levels = 2
if (measure == 'volunteer') factor_levels = length(low_high_label)
for (i in seq(1.5, ncol(wmat_all)-0.5, factor_levels)) lines(c(i, i), c(0, 1), col= adjustcolor("#000000", alpha.f = 0.4))

#rect(1.5, -1, 3.5, 1, col= adjustcolor(col[1], alpha.f = 0.2), lty=0)
#rect(5.5, -1, 7.5, 1, col= adjustcolor(col[2], alpha.f = 0.2), lty=0)
#rect(9.5, -1, 11.5, 1, col= adjustcolor(col[3], alpha.f = 0.2), lty=0)

# draw arrows between all combinations
if (draw_arrows) {
  arrow_seq = 2  # 2 for every second
  if (measure == 'volunteer') arrow_seq = 1
  for (n in seq(2, ncol(wmat_all)-1, arrow_seq)){
    arrows(n, wmat_all[, ord[n-1]+1], n+1, wmat_all[, ord[n]+1], length=0.15,
           col=adjustcolor(col[match(rownames(wmat_all), objnames)], alpha.f=0.5))
    
    comp = colnames(wmat)[n]
    for (ver_i in 1:length(rownames(wmat))) {
      ver = rownames(wmat)[ver_i]
      key = paste(ver, comp, collapse='', sep=':')
      print(key)
      if (!is.na(foo[[key, 2]]) && foo[[key, 2]] < 0.05) {
        # make this arrow red
        print(c(key, foo[[key, 2]]))
        arrows(n, wmat_all[ver_i, ord[n-1]+1], n+1, wmat_all[ver_i, ord[n]+1], length=0.15, lwd=1.3, col="red")
      }
    }
  }
}

dev.off()

# Findings
# scales amotivation and/or external are correlated with an increase preferance for C over A (crossing over)
# scales integrated and/or intrinsic are correlated with an increase preferance for A over C (but only almost crossing over)
# Within the 3 needs,
# scale amotivation is correlated with an increase prefarance of AA over CC
# scale intrinsic is correlated with an increase in prefarance of AA over CC
# BL and I are low value and of insignficant difference across all scales
# 


