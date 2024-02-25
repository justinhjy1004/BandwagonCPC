#===============================================================
# Author: Justino
#
# Analysis of the bandwagon effect
#===============================================================

library(tidyverse)
library(stargazer)
library(kableExtra)

df <- read_csv("data.csv")
# Make it to percentage
df$diff_growth <- 100*df$diff_growth 

years <- df |>
  filter( year >= 1985 ) |>
  group_by(year) |>
  summarize( count = n() ) |>
  mutate( weight = count/nrow(df))

## Vanilla Regression
lmod <- lm(switch ~ diff_growth + log1p(num_citation) + as.factor(year), df)
summary(lmod)

## Effect Size Analysis
average_year_effect <- sum(lmod$coefficients[-c(2,3)] * years$weight)
average_citation_effect <- mean(log1p(df$num_citation)) * lmod$coefficients[["log1p(num_citation)"]]

diff_growth <- quantile(df$diff_growth, probs = seq(0, 1, by = 0.001), na.rm = T)

y <- (diff_growth * lmod$coefficients[["diff_growth"]]) + average_year_effect + average_citation_effect

ggplot(mapping = aes(x=diff_growth, y = y)) +
  geom_point()

#===============================================================
# Sensitivity Analysis
#===============================================================

lmod <- lm(switch ~ diff_growth, df)
summary(lmod)

lmod <- lm(switch ~ diff_growth + log1p(num_citation), df)
summary(lmod)

lmod <- lm(switch ~ diff_growth + log1p(num_citation) + as.factor(year), df)
summary(lmod)

lmod <- lm(switch ~ diff_growth + log1p(num_citation) + as.factor(year) + as.factor(prev_cpc_section) , df)
summary(lmod)

lmod <- lm(switch ~ diff_growth + log1p(num_citation) + as.factor(year) + as.factor(prev_cpc_section) + as.factor(cpc_section) , df)
summary(lmod)

#===============================================================
# Logit and Probit
#===============================================================

logit <- glm(switch ~ diff_growth + log1p(num_citation) + as.factor(year), 
             family = binomial(link = "logit"), 
             data = df)

summary(logit)
  
probit <- glm(switch ~ diff_growth + log1p(num_citation) + as.factor(year), 
                  family = binomial(link = "probit"), 
                  data = df)
summary(probit)

#===============================================================
# Regression by Net Citation and Net Patents
#===============================================================

df |>
  ungroup() |>
  group_by(assignee_id) |>
  mutate(total_citation_count = sum(num_citation)) -> df

lmod <- lm(switch ~ diff_growth*log1p(num_patents) + log1p(num_citation) + as.factor(year) , df)
summary(lmod)

lmod <- lm(switch ~ diff_growth*log1p(total_citation_count) + log1p(num_citation) + as.factor(year) , df)
summary(lmod)
