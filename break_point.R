library(ggplot2)
library(ggjoy)
library(rstanarm)
library(dplyr)
library(tidybayes)
library(segmented)
library(lme4)
library(optimx)
library(mgcv)
library(brms)
library(schoenberg)
library(gamm4)

#rm(list = ls())
set.seed(20200604)

# Merged data, 3 sessions, log[e] ratio
# cds
cds.results = read.csv("cds_results.csv",header = TRUE, sep="\t")
cds.results$diff = cds.results$causative - 
  cds.results$random
cds.results$ratio = cds.results$causative /
  cds.results$random
# ggplot(filter(cds.results,name!="Ruth"), aes(age, diff))+
#   geom_smooth()+
#   geom_point()

# child
cs.results = read.csv("child_results.csv",header = TRUE, sep="\t")
cs.results$diff = cs.results$causative - cs.results$random
cs.results$ratio = cs.results$causative /
  cs.results$random
# ggplot(cs.results, aes(age, diff))+
#   geom_smooth()+
#   geom_point()
# ggplot(cds.results, aes(age, diff,color="cds"))+
#   theme_bw()+
#   geom_smooth(method = "loess")+
#   geom_smooth(data=cs.results,
#               aes(age,diff,color="child"), method = "loess")+
#   facet_wrap(vars(name))

full.results = cbind(cds.results, cs.results$diff)
colnames(full.results)[6] = "cds_diff"
colnames(full.results)[8] = "cs_diff"
full.results$diff = full.results$cds_diff - 
  full.results$cs_diff

# ggplot(filter(full.results,
#               age > 24 & age < 36),
#        aes(age, cds_diff-cs_diff))+
#   theme_bw()+
#   geom_smooth(method = "loess")+
#   geom_point()+
#   facet_wrap(vars(name))

#save.image("merge_1_model_comp.RData")

break.points = data.frame()

cds.segmented = list()
for (child in levels(full.results$name)){
  lm.model = lm(diff~age,
             data=filter(cds.results,name==child))
  #segmented.model = segmented(lm.model, seg.Z = ~age, psi=c(27,30))
  
  #cds.segmented[[child]] = segmented.model
  print(child)
  print(pscore.test(lm.model, n.break = 1))
  #print(segmented.model$psi)
  #if (!is.null(segmented.model$psi)){
  #  print(slope(segmented.model)) 
  #}
}

cs.segmented = list()
for (child in levels(full.results$name)){
  lm.model = lm(diff~age,
                data=filter(cs.results,name==child))
  segmented.model = segmented(lm.model, seg.Z = ~age, psi=c(28,30))
  cs.segmented[[child]] = segmented.model
  print(child)
  print(segmented.model$psi[2])
  if (!is.null(segmented.model$psi)){
    print(slope(segmented.model)) 
  }
}

full.segmented = list()
for (child in levels(full.results$name)){
  lm.model = lm(diff~age,
                data=filter(full.results,name==child))
  segmented.model = segmented(lm.model, seg.Z = ~age)
  full.segmented[[child]] = segmented.model
  print(child)
  print(segmented.model$psi[2])
  if (!is.null(segmented.model$psi)){
    print(slope(segmented.model)) 
  }
}
