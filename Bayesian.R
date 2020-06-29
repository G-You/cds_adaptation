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
merged.3.cds.results$diff = merged.3.cds.results$causative - 
  merged.3.cds.results$random
merged.3.cds.results$ratio = merged.3.cds.results$causative /
  merged.3.cds.results$random
ggplot(merged.3.cds.results, aes(age, diff))+
  geom_smooth()+
  geom_point()


model.merged.cds = stan_lmer(diff~ age+(1+age|name),
                      data = merged.3.cds.results,
                      prior_intercept = student_t(df=5,location=0),
                      prior = student_t(df=5,location=0),
                      cores = 4, 
                      seed = 1, 
                      iter = 4000,
                      adapt_delta = 0.99)

freq.model.merged.cds = lmer(diff~age+(1+age|name), 
                             data=merged.3.cds.results,
                             control = lmerControl(optimizer = "optimx", calc.derivs = FALSE,
                                                   optCtrl = list(method = "nlminb", starttests = FALSE, kkt = FALSE)))

model.merged.cds.random = stan_lmer(random~ age+(1+age|name),
                             data = merged.3.cds.results,
                             prior_intercept = student_t(df=5,location=0),
                             prior = student_t(df=5,location=0),
                             cores = 4,
                             iter = 4000,
                             adapt_delta = 0.99)

merged.3.cs.results = read.csv("child_results.csv",header = TRUE, sep="\t")
merged.3.cs.results$diff = merged.3.cs.results$causative - merged.3.cs.results$random
merged.3.cs.results$ratio = merged.3.cs.results$causative /
  merged.3.cs.results$random
ggplot(merged.3.cs.results, aes(age, diff))+
  geom_smooth()+
  geom_point()
ggplot(merged.3.cds.results, aes(age, diff,color="cds"))+
  theme_bw()+
  geom_smooth(method = "loess")+
  geom_smooth(data=merged.3.cs.results,
              aes(age,diff,color="child"), method = "loess")+
  facet_wrap(vars(name))
# ggplot(merged.3.cds.results, aes(age, ratio,color="cds"))+
#   theme_bw()+
#   geom_smooth(method = "loess")+
#   geom_smooth(data=merged.3.cs.results,
#               aes(age,ratio,color="child"), method = "loess")+
#   geom_point()+
#   facet_wrap(vars(name))
model.merged.cs = brm(diff ~ age+(1+age|name),
                              data = merged.3.cs.results,
                              prior = prior(student_t(5, 0, 3)),
                              cores = 4, 
                              seed = 1,
                              control = list(adapt_delta = 0.99999))
model.merged.cs.random = stan_lmer(random~ age+(1+age|name),
                                    data = merged.3.cs.results,
                                    prior_intercept = student_t(df=5,location=0),
                                    prior = student_t(df=5,location=0),
                                    cores = 4, 
                                    adapt_delta = 0.99)

# # correlation random and caus?
# 
# model.merged.cds.cor = stan_lmer(causative ~ random +(1+random|name),
#                                    data = merged.3.cds.results,
#                                    prior_intercept = student_t(df=5,location=0),
#                                    prior = student_t(df=5,location=0),
#                                    cores = 4, 
#                                    adapt_delta = 0.99)

merged.3.full.results = cbind(merged.3.cds.results, merged.3.cs.results$diff)
colnames(merged.3.full.results)[6] = "cds_diff"
colnames(merged.3.full.results)[8] = "cs_diff"
merged.3.full.results$diff = merged.3.full.results$cds_diff - 
  merged.3.full.results$cs_diff

model.merged.full = stan_lmer(cds_diff - cs_diff ~ age+(1+age|name),
                             data = filter(merged.3.full.results,
                                           age > 25 & age < 36),
                             prior_intercept = student_t(df=5,location=0),
                             prior = student_t(df=5,location=0),
                             cores = 4, 
                             iter = 4000,
                             seed = 1,
                             adapt_delta = 0.99)
ggplot(filter(merged.3.full.results,
              age > 25 & age < 36),
       aes(age, cds_diff-cs_diff))+
  theme_bw()+
  geom_smooth(method = "loess")+
  geom_point()
  #facet_wrap(vars(name))

# Bayesian GAM

gam.merged.cds = gamm(formula = diff~s(age),
                    correlation = corCAR1(value = 0.5, form = ~ 1+ age | name),
                    data=merged.3.cds.results)
plot(gam.merged.cds$lme)
draw(gam.merged.cds$gam)
gam.merged.cs = gamm4(formula = diff~s(age),
                     random=~(1+age|name),
                     data=merged.3.cs.results)
draw(gam.merged.cs$gam)

# mgcv gam

gam.merged.cds = gam(diff~age+s(name,bs="re"),
                     data=merged.3.cds.results)
summary(gam.merged.cds)

# mixed-effect segmented model

#bp = 30

b1 <- function(x, bp) ifelse(x < bp, bp - x, 0)# before slope
b2 <- function(x, bp) ifelse(x < bp, 0, x - bp) # after slope

foo <- function(bp, dataset)
{
  # freq.model.merged.cds = lmer(diff~b1(age,bp)+
  #                                b2(age,bp)+
  #                                (1+b1(age,bp)+b2(age,bp)|name),
  #                              data=merged.3.cds.results,
  #                              control = lmerControl(optimizer = "optimx", calc.derivs = FALSE,
  #                                                    optCtrl = list(method = "nlminb", starttests = FALSE, kkt = FALSE)))

  # freq.model.merged.full = lmer(cds_diff-cs_diff~b1(age,bp)+
  #                                b2(age,bp)+
  #                                (1+b1(age,bp)+b2(age,bp)|name),
  #                              data=merged.3.full.results,
  #                              control = lmerControl(optimizer = "optimx", calc.derivs = FALSE,
  #                                                    optCtrl = list(method = "nlminb", starttests = FALSE, kkt = FALSE)))
    model.merged.cds = stan_lmer(diff~ b1(age, bp) +
                                 b2(age, bp) +
                                 (1 + b1(age,bp)+
                                    b2(age,bp)|name),
                               data = dataset,
                               prior_intercept = student_t(df=5,location=0),
                               prior = student_t(df=5,location=0),
                               cores = 4,
                               seed = 1,
                               iter = 4000,
                               adapt_delta = 0.9999)
  #mod <- lmer(Reaction ~ b1(Days, bp) + b2(Days, bp) + (b1(Days, bp) + b2(Days, bp) | Subject), data = sleepstudy)
  #deviance(freq.model.merged.cds, REML=FALSE)
   loo(model.merged.cds)
}

get_loo <- function(model){
  loo(model)
}
#search.range <- c(min(merged.3.cs.results$age)+0.5,
#                  max(merged.3.cs.results$age)-0.5)
search.range <- c(25.5, 35.5)
#foo.opt <- optimize(foo, interval = search.range)
#bp <- foo.opt$minimum
search.grid <- sort(unique(subset(merged.3.cds.results, age > search.range[1] &
                                    age<search.range[2], "age", drop=TRUE)))

#res <- unlist(lapply(as.list(search.grid), foo))
cds.model.list = lapply(as.list(search.grid), foo, dataset = merged.3.cds.results)
#cds.loo.list = lapply(cds.model.list,get_loo)
cds.model.comp = loo_model_weights(cds.model.list)

cs.model.list = lapply(as.list(search.grid), foo, dataset = merged.3.cs.results)
cs.model.comp = loo_model_weights(cs.model.list)

full.model.list = lapply(as.list(search.grid), foo, dataset = merged.3.full.results)
full.model.comp = loo_model_weights(full.model.list)

plot(search.grid, res, type="l")
bp_grid <- search.grid[which.min(res)]
# model.merged.cds = stan_lmer(diff~ b1(age, bp) +
#                                b2(age, bp) +
#                                (1 + b1(age,bp)+
#                                   b2(age,bp)|name),
#                              data = merged.3.cds.results,
#                              prior_intercept = student_t(df=5,location=0),
#                              prior = student_t(df=5,location=0),
#                              cores = 4, 
#                              seed = 1, 
#                              iter = 4000,
#                              adapt_delta = 0.99)
# freq.model.merged.full = lmer(cds_diff-cs_diff~b1(age,bp)+
#                                 b2(age,bp)+
#                                 (1+b1(age,bp)+b2(age,bp)|name),
#                               data=merged.3.full.results,
#                               control = lmerControl(optimizer = "optimx", calc.derivs = FALSE,
#                                                     optCtrl = list(method = "nlminb", starttests = FALSE, kkt = FALSE)))
# 

# brm to compare models with different breakpoints

age.range = 26:35
b1 <- function(x, bp) ifelse(x < bp, bp - x, 0)# before slope
b2 <- function(x, bp) ifelse(x < bp, 0, x - bp) # after slope

bp.analysis = function(age.range, dataset){
  
  model.list = list()
  loo.list = list()
  # this is more than ridiculous but ultimately a solution to insert dynamic number into this formula, Jesus
  
  for (bp in age.range){
    # build model
    # model.temp = stan_lmer(diff~ b1(age, bp) +
    #                         b2(age, bp) +
    #                         (1 + b1(age,bp)+
    #                         b2(age,bp)|name),
    #                         data = dataset,
    #                         prior_intercept = student_t(df=5,location=0),
    #                         prior = student_t(df=5,location=0),
    #                         cores = 4,
    #                         seed = 1,
    #                         iter = 4000,
    #                         adapt_delta = 0.999999)
    f = as.formula(paste("diff~ b1(age,", bp,
                         ") + b2(age, ", bp,
                         ") + (1 + b1(age," ,bp,
                         ")+ b2(age,",bp,
                         ")|name)"))
    model.temp = brm(f,
                     data = dataset,
                     prior = prior(student_t(5, 0, 3)),
                     cores = 4,
                     seed = 1,
                     iter = 4000,
                     control = list(adapt_delta = 0.99999))
    # store model
    model.list[["bp"]] = model.temp
    # loo
    loo.list[["bp"]] = loo(model.temp, reloo = TRUE) 
  }
  
  return(list("model" = model.list, "loo" = loo.list))
}

bp.results.cds = bp.analysis(age.range, merged.3.cds.results)
bp.results.cs = bp.analysis(age.range, merged.3.cs.results)
bp.results.full = bp.analysis(age.range, merged.3.full.results)
save.image("~/Documents/UZH/papers/paper2/bp_06042020.RData")


