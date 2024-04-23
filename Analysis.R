#===============================================================
# Author: Justino
#
# Analysis of the bandwagon effect
#===============================================================
rm(list = ls())

library(tidyverse)
library(stargazer)
library(kableExtra)

df <- read_csv("data.csv")

# Convert to percentage
df$diff_growth <- 100*df$diff_growth 

## Vanilla Regression

### OLS
lmod <- lm(switch ~ diff_growth + log1p(num_citation) + as.factor(year), df)
summary(lmod)

### LOGIT
logit <- glm(switch ~ diff_growth + log1p(num_citation) + as.factor(year), 
             family = binomial(link = "logit"), 
             data = df)

summary(logit)

### PROBIT
probit <- glm(switch ~ diff_growth + log1p(num_citation) + as.factor(year), 
              family = binomial(link = "probit"), 
              data = df)

summary(probit)

#===============================================================
#                     "Effect" Size Analysis
#===============================================================

years <- df |>
  filter( year >= 1985 ) |>
  group_by(year) |>
  summarize( count = n() ) |>
  mutate( weight = count/nrow(df))

average_year_effect <- sum(lmod$coefficients[-c(2,3)] * years$weight)
average_citation_effect <- mean(log1p(df$num_citation)) * lmod$coefficients[["log1p(num_citation)"]]

diff_growth <- quantile(df$diff_growth, probs = seq(0, 1, by = 0.001), na.rm = T)

y <- (diff_growth * lmod$coefficients[["diff_growth"]]) + average_year_effect + average_citation_effect

#===============================================================
#                     At Least N year(s) apart
#===============================================================
# This is mainly to see if the relationship holds
# if we only consider patents that were filed at least
# N year(s) apart

N <- 1

df |>
  group_by(assignee_id) |>
  mutate(lag_year = lag(year),
         years_apart_from_last = year - lag_year) |>
  filter( years_apart_from_last > N ) -> df_years

## Vanilla Regression

### OLS
lmod <- lm(switch ~ diff_growth + log1p(num_citation) + as.factor(year), df_years)
summary(lmod)

### LOGIT
logit <- glm(switch ~ diff_growth + log1p(num_citation) + as.factor(year), 
             family = binomial(link = "logit"), 
             data = df_years)

summary(logit)

### PROBIT
probit <- glm(switch ~ diff_growth + log1p(num_citation) + as.factor(year), 
              family = binomial(link = "probit"), 
              data = df_years)

summary(probit)

## Interaction

### OLS
lmod <- lm(switch ~ diff_growth * log1p(num_citation) + as.factor(year), df_years)
summary(lmod)

### LOGIT
logit <- glm(switch ~ diff_growth * log1p(num_citation) + as.factor(year), 
             family = binomial(link = "logit"), 
             data = df_years)

summary(logit)

### PROBIT
probit <- glm(switch ~ diff_growth * log1p(num_citation) + as.factor(year), 
              family = binomial(link = "probit"), 
              data = df_years)

summary(probit)

#===============================================================
#                     Exclude the Ys
#===============================================================
# 

df |>
  filter(cpc_section != "Y", prev_cpc_section != "Y") -> df_Y

## Vanilla Regression

### OLS
lmod <- lm(switch ~ diff_growth + log1p(num_citation) + as.factor(year), df_Y)
summary(lmod)

### LOGIT
logit <- glm(switch ~ diff_growth + log1p(num_citation) + as.factor(year), 
             family = binomial(link = "logit"), 
             data = df_Y)

summary(logit)


#===============================================================
#                       Summary Stats
#===============================================================

data <- df[,c("diff_growth", "num_citation")]
data$num_citation <- log1p(data$num_citation)

summary(data$diff_growth)
summary(data$num_citation)

#===============================================================
#                 Direct Growth Difference
#===============================================================
n <- 2

df <- read_csv("data.csv")
prod <- read_csv("cpc_section_production.csv")

prod |>
  arrange(cpc_section, year) |>
  filter(year != 2023) |>
  mutate( 
    count.l1 = lag(count),
    growth_rate = 100*(count-count.l1)/count,
    year_decide = year - n
  ) |>
  select( cpc_section, year_decide, growth_rate ) -> prod

df |>
  left_join(prod, by = c("year" = "year_decide", "prev_cpc_section" = "cpc_section")) |>
  rename(prev_section_growth_rate = growth_rate) |>
  left_join(prod, by = c("year" = "year_decide", "cpc_section" = "cpc_section")) |>
  rename(current_section_growth_rate = growth_rate) |>
  mutate(direct_diff_growth = prev_section_growth_rate - current_section_growth_rate) -> df

## Vanilla Regression

### OLS
lmod <- lm(switch ~ direct_diff_growth + log1p(num_citation) + as.factor(year), df)
summary(lmod)

### LOGIT
logit <- glm(switch ~ direct_diff_growth + log1p(num_citation) + as.factor(year), 
             family = binomial(link = "logit"), 
             data = df)

summary(logit)

### PROBIT
probit <- glm(switch ~ direct_diff_growth + log1p(num_citation) + as.factor(year), 
              family = binomial(link = "probit"), 
              data = df)

summary(probit)
