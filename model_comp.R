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
library(bayestestR)
library(logspline)
library(ggridges)
library(forcats)
library(tidyverse)
library(rlist)

rm(list = ls())
set.seed(20200604)

# Merged data, 3 sessions, log[e] ratio
# cds
cds.results = read.csv("cds_results_merge_1_random_verb_1000_edge_ratio_50.csv",header = TRUE, sep="\t")
cds.results$diff = cds.results$causative - 
  cds.results$random
cds.results$ratio = cds.results$causative /
  cds.results$random
# ggplot(filter(cds.results,name!="Ruth"), aes(age, diff))+
#   geom_smooth()+
#   geom_point()
model.cds = brm(diff~age+(1+age|name),
                 data = cds.results,
                 prior = prior(student_t(5, 0, 3)),
                 cores = 4,
                 seed = 1,
                 iter = 4000,
                 control = list(adapt_delta = 0.99999))
model.cds.non = brm(diff~1|name,
                data = cds.results,
                cores = 4,
                seed = 1,
                iter = 4000,
                control = list(adapt_delta = 0.99999))


# child
cs.results = read.csv("child_results_merge_1_random_verb_1000_edge_ratio_50.csv",header = TRUE, sep="\t")
cs.results$diff = cs.results$causative - cs.results$random
cs.results$ratio = cs.results$causative /
  cs.results$random
# ggplot(cs.results, aes(age, diff))+
#   geom_smooth()+
#   geom_point()
ggplot(cds.results, aes(age, diff,color="cds"))+
  theme_bw()+
  geom_smooth(method = "loess", span=0.7)+
  geom_smooth(data=cs.results,
              aes(age,diff,color="child"), method = "loess",span=0.7)+
  facet_wrap(vars(name))

# ggplot(cds.results, aes(age, random,color="cds"))+
#   theme_bw()+
#   geom_point()+
#   geom_point(data=cs.results,
#               aes(age,random,color="child"))+
#   facet_wrap(vars(name))

model.cs = brm(diff~age+(1+age|name),
                data = cs.results,
                prior = prior(student_t(5, 0, 3)),
                cores = 4,
                seed = 1,
                iter = 4000,
                control = list(adapt_delta = 0.99999))
model.cs.non = brm(diff~1|name,
               data = cs.results,
               cores = 4,
               seed = 1,
               iter = 4000,
               control = list(adapt_delta = 0.99999))

full.results = cbind(cds.results, cs.results$diff)
colnames(full.results)[6] = "cds_diff"
colnames(full.results)[8] = "cs_diff"
full.results$diff = full.results$cds_diff - 
  full.results$cs_diff
full.results$random = cds.results$random - 
  cs.results$random

# ggplot(filter(full.results,
#               age > 24 & age < 36),
#        aes(age, cds_diff-cs_diff))+
#   theme_bw()+
#   geom_smooth(method = "loess")+
#   geom_point()+
# facet_wrap(vars(name))
model.full = brm(diff~age+(1+age|name),
                data = full.results,
                prior = prior(student_t(5, 0, 3)),
                cores = 4,
                seed = 1,
                iter = 4000,
                control = list(adapt_delta = 0.99999))
model.full.non = brm(diff~1|name,
                 data = full.results,
                 cores = 4,
                 seed = 1,
                 iter = 4000,
                 control = list(adapt_delta = 0.99999))


loo.cds = loo(model.cds, reloo=TRUE)
loo.cs = loo(model.cs, reloo=TRUE)
loo.full = loo(model.full, reloo=TRUE)

loo.cds.non = loo(model.cds.non, reloo=TRUE)
loo.cs.non = loo(model.cs.non, reloo=TRUE)
loo.full.non = loo(model.full.non, reloo=TRUE)

bp1.results = readRDS("bp_revised_edge_merge_1_bp1_loo.rds")
bp2.results = readRDS("bp_revised_edge_merge_1_bp2_loo.rds")

cds.loos = Map(c,bp1.results[1],bp2.results[1])[[1]]
cds.loos$full = loo.cds
cds.loos$non = loo.cds.non
cs.loos = Map(c,bp1.results[2],bp2.results[2])[[1]]
cs.loos$full = loo.cs
cs.loos$non = loo.cs.non
full.loos = Map(c,bp1.results[3],bp2.results[3])[[1]]
full.loos$full = loo.full
full.loos$non = loo.full.non

comp.cds = loo_model_weights(cds.loos,method = "pseudobma")
comp.cs = loo_model_weights(cs.loos,method = "pseudobma")
comp.full = loo_model_weights(full.loos,method = "pseudobma")

results.comp.cds = data.frame(model = names(comp.cds),
                              weight = c(unname(comp.cds)))
results.comp.cs = data.frame(model = names(comp.cs),
                              weight = c(unname(comp.cs)))
results.comp.full = data.frame(model = names(comp.full),
                              weight = c(unname(comp.full)))

cds.x.breaks = c("25",rep("",each=35),"30.32",rep("",each=9),"full","non")
ggplot(results.comp.cds,aes(x=model, y=weight))+
  geom_bar(stat = "identity")+
  scale_x_discrete(breaks=cds.x.breaks)+
  theme_bw()
ggsave("Figure1B.pdf",width = 12, height = 5)

cs.x.breaks = c(rep("",each=24),"28.30",rep("",each=21),"full","non")
ggplot(results.comp.cs,aes(x=model, y=weight))+
  geom_bar(stat = "identity")+
  scale_x_discrete(breaks=cs.x.breaks)+
  theme_bw()
ggsave("Figure1A.pdf",width = 12, height = 5)

full.x.breaks = c(rep("",each=19),"27.30",rep("",each=5),
                  "28.30",rep("",each=10), "30.32",rep("",each=9),"full","non")
ggplot(results.comp.full,aes(x=model, y=weight))+
  geom_bar(stat = "identity")+
  scale_x_discrete(breaks=full.x.breaks)+
  theme_bw()
ggsave("Figure3A.pdf",width = 12, height = 5)

# cds.loos.temp = list.remove(cds.loos,
#                             c("25.27","26.28","27.29","28.30","29.31","30.32","31.33","32.34"))
# cs.loos.temp = list.remove(cs.loos,
#                             c("25.27","26.28","27.29","28.30","29.31","30.32","31.33","32.34"))
# full.loos.temp = list.remove(full.loos,
#                             c("25.27","26.28","27.29","28.30","29.31","30.32","31.33","32.34"))

# comp.cds = loo_model_weights(cds.loos)
# comp.cs = loo_model_weights(cs.loos)
# comp.full = loo_model_weights(full.loos)

#save.image("merge_1_model_comp.RData")

# examine best models
# b1 <- function(x, bp1) ifelse(x <= bp1, x - 22, bp1 - 22) # 1st slope
# b2 <- function(x, bp1, bp2) ifelse(x <= bp1, 0, ifelse(x <= bp2, x - bp1, bp2 - bp1)) # 2nd slope
# b3 <- function(x, bp2) ifelse(x >= bp2, x - bp2, 0)

b1 <- function(x, bp1) ifelse(x < bp1, x - 22, x - 22)
b2 <- function(x, bp1, bp2) ifelse(x < bp1, 0,  x - bp1)
b3 <- function(x, bp2) ifelse(x < bp2, 0, x - bp2)

model.cds.30.32 = brm( diff ~ b1(age, 30)+
                   b2(age, 30, 32) +
                   b3(age, 32) +
                   (1 + b1(age, 30) + b2(age, 30, 32)+
                      b3(age, 32)| name),
                 data = cds.results,
                 prior = prior(student_t(5, 0, 3)),
                 cores = 4,
                 seed = 1,
                 iter = 4000,
                 control = list(adapt_delta = 0.99999))

# sensetivity on intercept prior

model.cds.30.32.alpha = brm( diff ~ b1(age, 30)+
                         b2(age, 30, 32) +
                         b3(age, 32) +
                         (1 + b1(age, 30) + b2(age, 30, 32)+
                            b3(age, 32)| name),
                       data = cds.results,
                       prior = c(
                         prior(student_t(5, 0, 3), class= b),
                         prior(student_t(5, 0, 3), class= Intercept)),
                       cores = 4,
                       seed = 1,
                       iter = 4000,
                       control = list(adapt_delta = 0.99999))


model.cds.29.32 = brm( diff ~ b1(age, 29)+
                         b2(age, 29, 32) +
                         b3(age, 32) +
                         (1 + b1(age, 29) + b2(age, 29, 32)+
                            b3(age, 32)| name),
                       data = cds.results,
                       prior = prior(student_t(5, 0, 3)),
                       cores = 4,
                       seed = 1,
                       iter = 2000,
                       control = list(adapt_delta = 0.99999))

# plot coef

model.cds.30.32 %>%
  spread_draws(b_b1age30,b_b2age3032,b_b3age32) %>%
  mutate(age1 = b_b1age30,
         age2 = b_b1age30 + b_b2age3032,
         age3 = b_b1age30 + b_b2age3032 + b_b3age32) %>%
  gather(.variable, .value, age1:age3) %>%
  ggplot(aes(x=.value, y=.variable))+
  stat_intervalh(.width = c(.50, .80, .90, .95),point_interval = median_qi)+
  scale_color_brewer()+
  scale_y_discrete(labels=c("<30","30-32",">32"))+
  ylab("age\n")+
  xlab("\ncoefficient estimate")+
  geom_vline(xintercept = 0, linetype="dotted")+
  theme_bw()
ggsave("Figure2D.pdf",width = 7,height=4)

# for group level summary
print(summary(model.cds.30.32),digits=5)
summary.cds.30.32 = as.data.frame(model.cds.30.32)
plot(marginal_effects(model.cds.30.32,
                      probs = c(0.05,0.95),
                      method = "predict"),
     points = TRUE)[[1]]+
  theme_bw()+
  ylab("above-baseline causative complexity")+
  xlab("age in months")+
  scale_x_continuous(breaks = seq(22,36,1))
ggsave("Figure2C.pdf",width = 7, height = 5)

plot(marginal_effects(model.cds.30.32, "age",
                      probs = c(0.05,0.95),
                      method = "predict",
                      conditions = distinct(cds.results,name),re_formula = NULL),
     points = TRUE,
     rug = TRUE)[[1]]+
  theme_bw()
cds.30.32.b1 = summary.cds.30.32$b_b1age30
cds.30.32.b2 = summary.cds.30.32$b_b2age3032
cds.30.32.b3 = summary.cds.30.32$b_b3age32
mean(cds.30.32.b1>0)
mean(cds.30.32.b1 + cds.30.32.b2<0)
mean(cds.30.32.b1 + cds.30.32.b2 + cds.30.32.b3>0)

# individual level of a certain variable
#summary.cds.30.32 = as_tibble(posterior_samples(model.cds.30.32, pars = "b1age30"))
out_r <- spread_draws(model.cds.30.32, r_name[name,term], b_b2age3032) %>% 
  mutate(b_b2age3032 = r_name + b_b2age3032) 
out_f <- spread_draws(model.cds.30.32, b_b2age3032) %>% 
  mutate(name = "Average")
out_all <- bind_rows(out_r, out_f) %>% 
  ungroup() %>%
  # Ensure that Average effect is on the bottom of the forest plot
  mutate(name = fct_relevel(name, "Average"))
out_all_sum <- group_by(out_all, name) %>% 
  mean_hdi(b_b2age3032,.width = 0.85)
out_all %>%   
  ggplot(aes(b_b2age3032, name)) +
  theme_bw()+
  geom_density_ridges(
    rel_min_height = 0.01, 
    col = NA,
    scale = 1
  ) +
  geom_pointintervalh(
    data = out_all_sum, size = 1
  ) +
  geom_text(
    data = mutate_if(out_all_sum, is.numeric, round, 3),
    # Use glue package to combine strings
    aes(label = glue::glue("{b_b2age3032} [{.lower}, {.upper}]"), x = Inf),
    hjust = "inward"
  )

model.cs.28.30 = brm( diff ~ b1(age, 28)+
                   b2(age, 28, 30) +
                   b3(age, 30) +
                   (1 + b1(age, 28) + b2(age, 28, 30)+
                      b3(age, 30)| name),
                 data = cs.results,
                 prior = prior(student_t(5, 0, 3)),
                 cores = 4,
                 seed = 1,
                 iter = 4000,
                 control = list(adapt_delta = 0.99999))
print(summary(model.cs.28.30,prob=0.9),digits=5)
plot(marginal_effects(model.cs.28.30,
                      probs = c(0.05,0.95),
                      method = "predict"),
     points = TRUE)[[1]]+
  theme_bw()+
  ylab("above-baseline causative complexity")+
  xlab("age in months")+
  scale_x_continuous(breaks = seq(22,36,1))
ggsave("Figure2A.pdf",width = 7, height = 5)

plot(marginal_effects(model.cs.28.30, "age",
                      probs = c(0.05,0.95),
                      method = "predict",
                      conditions = distinct(cds.results,name),re_formula = NULL),
     points = TRUE,
     rug = TRUE)[[1]]+
  theme_bw()


model.cs.28.30 %>%
  spread_draws(b_b1age28,b_b2age2830,b_b3age30) %>%
  mutate(age1 = b_b1age28,
         age2 = b_b1age28 + b_b2age2830,
         age3 = b_b1age28 + b_b2age2830 + b_b3age30) %>%
  gather(.variable, .value, age1:age3) %>%
  ggplot(aes(x=.value, y=.variable))+
  stat_intervalh(.width = c(.50, .80, .90, .95),point_interval = median_qi)+
  scale_color_brewer()+
  scale_y_discrete(labels=c("<28","28-30",">30"))+
  ylab("age\n")+
  xlab("\ncoefficient estimate")+
  geom_vline(xintercept = 0, linetype="dotted")+
  theme_bw()
ggsave("Figure2B.pdf",width = 7,height=4)


summary.cs.28.30 = as.data.frame(model.cs.28.30)
cs.28.30.b1 = summary.cs.28.30$b_b1age28
cs.28.30.b2 = summary.cs.28.30$b_b2age2830
cs.28.30.b3 = summary.cs.28.30$b_b3age30
qi(cs.28.30.b1, .width = 0.9)
qi(cs.28.30.b1 + cs.28.30.b2, .width = 0.9)
qi(cs.28.30.b1 + cs.28.30.b2 + cs.28.30.b3, .width = 0.9)

plot(marginal_effects(model.cs.28.30,probs = c(0.05,0.95),
                      method = "predict"),
     points = TRUE,
     rug = TRUE)[[1]]+
  theme_bw()

model.cs.28.31 = brm( diff ~ b1(age, 28)+
                        b2(age, 28, 31) +
                        b3(age, 31) +
                        (1 + b1(age, 28) + b2(age, 28, 31)+
                           b3(age, 31)| name),
                      data = cs.results,
                      prior = prior(student_t(5, 0, 3)),
                      cores = 4,
                      seed = 1,
                      iter = 2000,
                      control = list(adapt_delta = 0.99999))
marginal_effects(model.cs.28.30, 
                 probs = c(0.05, 0.95))
marginal_effects(model.cs.28.30, "age", 
                 probs = c(0.025, 0.975),
                 conditions = distinct(cds.results,name),re_formula = NULL)
out_r <- spread_draws(model.cs.28.30, r_name[name,term], b_b2age2830) %>% 
  mutate(b_b2age2830 = r_name + b_b2age2830) 
out_f <- spread_draws(model.cs.28.30, b_b2age2830) %>% 
  mutate(name = "Average")
out_all <- bind_rows(out_r, out_f) %>% 
  ungroup() %>%
  # Ensure that Average effect is on the bottom of the forest plot
  mutate(name = fct_relevel(name, "Average"))
out_all_sum <- group_by(out_all, name) %>% 
  mean_qi(b_b2age2830)
out_all %>%   
  ggplot(aes(b_b2age2830, name)) +
  theme_bw()+
  geom_density_ridges(
    rel_min_height = 0.01, 
    col = NA,
    scale = 1
  ) +
  geom_pointintervalh(
    data = out_all_sum, size = 1
  ) +
  geom_text(
    data = mutate_if(out_all_sum, is.numeric, round, 2),
    # Use glue package to combine strings
    aes(label = glue::glue("{b_b2age2830} [{.lower}, {.upper}]"), x = Inf),
    hjust = "inward"
  )

model.full.30.32 = brm( diff ~ b1(age, 30)+
                   b2(age, 30, 32) +
                   b3(age, 32) +
                   (1 + b1(age, 30) + b2(age, 30, 32)+
                      b3(age, 32)| name),
                 data = full.results,
                 prior = prior(student_t(5, 0, 3)),
                 cores = 4,
                 seed = 1,
                 iter = 4000,
                 control = list(adapt_delta = 0.99999))
summary.full.30.32 = as.data.frame(model.full.30.32)
full.30.32.b1 = summary.full.30.32$b_b1age30
full.30.32.b2 = summary.full.30.32$b_b2age3032
full.30.32.b3 = summary.full.30.32$b_b3age32
mean(full.30.32.b1 + full.30.32.b2 <0)


model.full.27.30 = brm( diff ~ b1(age, 27)+
                          b2(age, 27, 30) +
                          b3(age, 30) +
                          (1 + b1(age, 27) + b2(age, 27, 30)+
                             b3(age, 30)| name),
                        data = full.results,
                        prior = prior(student_t(5, 0, 3)),
                        cores = 4,
                        seed = 1,
                        iter = 4000,
                        control = list(adapt_delta = 0.99999))
summary.full.27.30 = as.data.frame(model.full.27.30)
full.27.30.b1 = summary.full.27.30$b_b1age27
full.27.30.b2 = summary.full.27.30$b_b2age2730
full.27.30.b3 = summary.full.27.30$b_b3age30
mean(full.27.30.b1 < 0)
mean(full.27.30.b1+ full.27.30.b2> 0)
mean(full.27.30.b1+ full.27.30.b2 + full.27.30.b3< 0)


plot(marginal_effects(model.full.27.30,
                      probs = c(0.05,0.95),
                      method = "predict"),
     points = TRUE)[[1]]+
  theme_bw()+
  ylab("above-baseline causative complexity")+
  xlab("age in months")+
  scale_x_continuous(breaks = seq(22,36,1))
ggsave("Figure3B.pdf",width = 6, height = 5)

model.full.27.30 %>%
  spread_draws(b_b1age27,b_b2age2730,b_b3age30) %>%
  mutate(age1 = b_b1age27,
         age2 = b_b1age27 + b_b2age2730,
         age3 = b_b1age27 + b_b2age2730 + b_b3age30) %>%
  gather(.variable, .value, age1:age3) %>%
  ggplot(aes(x=.value, y=.variable))+
  stat_intervalh(.width = c(.50, .80, .90, .95),point_interval = median_qi)+
  scale_color_brewer()+
  scale_y_discrete(labels=c("<30","30-32",">32"))+
  ylab("age\n")+
  xlab("\ncoefficient estimate")+
  geom_vline(xintercept = 0, linetype="dotted")+
  theme_bw()
ggsave("Figure3C.pdf",width = 5,height=4)


model.full.non = brm(diff~(1+name),
                     data = full.results,
                     prior = prior(student_t(5,0,3)),
                     cores = 4,
                     seed = 1,
                     iter = 2000,
                     control = list(adapt_delta = 0.99999))

cor.test(full.results$cds_diff, full.results$cs_diff, alternative = "greater")
save.image("edge_merge_1_model_comp.RData")

# more individuals

model.cds.30.32.anne = brm( diff ~ b1(age, 30)+
                         b2(age, 30, 32) +
                         b3(age, 32),
                       data = filter(cds.results,name=="Anne"),
                       prior = prior(student_t(5, 0, 3)),
                       cores = 4,
                       seed = 1,
                       iter = 4000,
                       control = list(adapt_delta = 0.99999))
model.cds.30.32.carl = brm( diff ~ b1(age, 30)+
                              b2(age, 30, 32) +
                              b3(age, 32),
                            data = filter(cds.results,name=="Carl"),
                            prior = prior(student_t(5, 0, 3)),
                            cores = 4,
                            seed = 1,
                            iter = 2000,
                            control = list(adapt_delta = 0.99999))
model.cds.30.32.domi = brm( diff ~ b1(age, 30)+
                              b2(age, 30, 32) +
                              b3(age, 32),
                            data = filter(cds.results,name=="Dominic"),
                            prior = prior(student_t(5, 0, 3)),
                            cores = 4,
                            seed = 1,
                            iter = 2000,
                            control = list(adapt_delta = 0.99999))
model.cds.30.32.gail = brm( diff ~ b1(age, 30)+
                              b2(age, 30, 32) +
                              b3(age, 32),
                            data = filter(cds.results,name=="Gail"),
                            prior = prior(student_t(5, 0, 3)),
                            cores = 4,
                            seed = 1,
                            iter = 2000,
                            control = list(adapt_delta = 0.99999))
model.cds.30.32.carl = brm( diff ~ b1(age, 30)+
                              b2(age, 30, 32) +
                              b3(age, 32),
                            data = filter(cds.results,name=="Carl"),
                            prior = prior(student_t(5, 0, 3)),
                            cores = 4,
                            seed = 1,
                            iter = 2000,
                            control = list(adapt_delta = 0.99999))
model.cds.30.32.carl = brm( diff ~ b1(age, 30)+
                              b2(age, 30, 32) +
                              b3(age, 32),
                            data = filter(cds.results,name=="Carl"),
                            prior = prior(student_t(5, 0, 3)),
                            cores = 4,
                            seed = 1,
                            iter = 2000,
                            control = list(adapt_delta = 0.99999))


# comparison of random baseline

random.bp1.results = readRDS("edge_merge_1_bp1_loo_random.rds")
random.bp2.results = readRDS("edge_merge_1_bp2_loo_random.rds")

random.cds.loos = Map(c,random.bp1.results[1],random.bp2.results[1])[[1]]
#cds.loos$full = loo.cds
random.cs.loos = Map(c,random.bp1.results[2],random.bp2.results[2])[[1]]
#cs.loos$full = loo.cs
random.full.loos = Map(c,random.bp1.results[3],random.bp2.results[3])[[1]]
#full.loos$full = loo.full

random.comp.cds = loo_model_weights(random.cds.loos,method="pseudobma")
random.comp.cs = loo_model_weights(random.cs.loos,method="pseudobma")
random.comp.full = loo_model_weights(random.full.loos,method="pseudobma")

random.model.cds.26.32 = brm( random ~ b1(age, 26)+
                          b2(age, 26, 32) +
                          b3(age, 32) +
                          (1 + b1(age, 26) + b2(age, 26, 32)+
                             b3(age, 32)| name),
                        data = cds.results,
                        prior = prior(student_t(5, 0, 3)),
                        cores = 4,
                        seed = 1,
                        iter = 2000,
                        control = list(adapt_delta = 0.99999))
random.model.cs.25.28 = brm( random ~ b1(age, 25)+
                          b2(age, 25, 28) +
                          b3(age, 28) +
                          (1 + b1(age, 25) + b2(age, 25, 28)+
                             b3(age, 28)| name),
                        data = full.results,
                        prior = prior(student_t(5, 0, 3)),
                        cores = 4,
                        seed = 1,
                        iter = 2000,
                        control = list(adapt_delta = 0.99999))
random.model.full.26.32 = brm( random ~ b1(age, 26)+
                          b2(age, 26, 32) +
                          b3(age, 32) +
                          (1 + b1(age, 26) + b2(age, 26, 32)+
                             b3(age, 32)| name),
                        data = full.results,
                        prior = prior(student_t(5, 0, 3)),
                        cores = 4,
                        seed = 1,
                        iter = 2000,
                        control = list(adapt_delta = 0.99999))



# vocab
cds_vocab_stats = read.table("cds_vocab_stats.txt")
colnames(cds_vocab_stats) = c("child","age","vocabulary")
cs_vocab_stats = read.table("child_vocab_stats.txt")
colnames(cs_vocab_stats) = c("child","age","vocabulary")
ggplot(cds_vocab_stats, aes(x=age,y=vocabulary))+
  geom_bar(stat = "identity")+
  facet_wrap(vars(child))+
  theme_bw()
ggsave("FigureS1A.pdf",width = 10, height = 4.5)
ggplot(cs_vocab_stats, aes(x=age,y=vocabulary))+
  geom_bar(stat = "identity")+
  facet_wrap(vars(child))+
  theme_bw()
ggsave("FigureS1B.pdf",width = 10, height = 4.5)

