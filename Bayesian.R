library(ggplot2)
library(ggjoy)
library(rstanarm)
library(dplyr)
library(tidybayes)

rm(list = ls())
set.seed(20191023)
full.data = data.frame(read.table("analysis_data.txt",header=FALSE))
colnames(full.data) = c("child","child_directed","child_speech","age")

model.diff = stan_lmer((child_speech-child_directed)~ age+(1+age|child),
                  data = full.data,
                  prior_intercept = student_t(df=5,location=0),
                  prior = student_t(df=5,location=0),
                  cores = 4, 
                  iter = 10000,
                  adapt_delta = 0.999999)
coefs.diff = data.frame(coefficient = unlist(as.data.frame(model.diff)[,1:2]),
                   predictor = rep(c("intercept","age"),each=20000))

model.cds = stan_lmer(child_directed~ age+(1+age|child),
                       data = full.data,
                       prior_intercept = student_t(df=5,location=0),
                       prior = student_t(df=5,location=0),
                       cores = 4, 
                       iter = 10000,
                       adapt_delta = 0.999999)
coefs.cds = data.frame(coefficient = unlist(as.data.frame(model)[,1:2]),
                        predictor = rep(c("intercept","age"),each=20000))

cor.test(tmp1$degree, tmp2$degree, method="pearson")
#ggplot(coefs,aes(y=predictor))+theme_bw()+stat_intervalh(aes(x = coefficient), point_interval = median_hdi, .width = c(.5, .8, .9, .95))+scale_color_brewer(name="Credible Interval",palette = 1) 
ggplot(tmp, aes(x=age,y=degree,group = genre))+theme_bw()+geom_smooth(method = "loess",aes(linetype=genre))+facet_wrap(vars(child),ncol=4,labeller = labeller(child=c("Anne"="Child 1","Aran"="Child 2","Becky"="Child 3","Carl"="Child 4","Dominic"="Child 5","Gail"="Child 6","Joel"="Child 7","John"="Child 8","Liz"="Child 9","Nicole"="Child 10","Ruth"="Child 11","Warren"="Child 12")))+geom_hline(yintercept = 4.24,linetype='twodash',show.legend = TRUE)+ylim(c(-1, 5))+ylab("average node degree\n")+xlab("\nage (month)")


# Merged data, 3 sessions, log[e] ratio
merged.3.cds.results = read.csv("cds_results.csv",header = TRUE, sep="\t")
merged.3.cds.results$diff = merged.3.cds.results$causative - merged.3.cds.results$random
ggplot(merged.3.cds.results, aes(age, diff))+
  geom_smooth()

model.merged.cds = stan_lmer(diff~ age+(1+age|name),
                      data = merged.3.cds.results,
                      prior_intercept = student_t(df=5,location=0),
                      prior = student_t(df=5,location=0),
                      cores = 4, 
                      adapt_delta = 0.99)

merged.3.cs.results = read.csv("child_results.csv",header = TRUE, sep="\t")
merged.3.cs.results$diff = merged.3.cs.results$causative - merged.3.cs.results$random
ggplot(merged.3.cs.results, aes(age, diff))+
  geom_smooth()

model.merged.cs = stan_lmer(diff ~ age+(1+age|name),
                              data = merged.3.cs.results,
                              prior_intercept = student_t(df=5,location=0),
                              prior = student_t(df=5,location=0),
                              cores = 4, 
                              adapt_delta = 0.99)

merged.3.full.results = cbind(merged.3.cds.results, merged.3.cs.results$diff)
colnames(merged.3.full.results)[5] = "cds_diff"
colnames(merged.3.full.results)[6] = "cs_diff"
model.merged.full = stan_lmer(cds_diff - cs_diff ~ age+(1+age|name),
                             data = merged.3.full.results,
                             prior_intercept = student_t(df=5,location=0),
                             prior = student_t(df=5,location=0),
                             cores = 4, 
                             adapt_delta = 0.99)
