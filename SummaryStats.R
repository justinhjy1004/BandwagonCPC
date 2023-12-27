#===============================================================
# Author: Justino
#
# Summary Stats and Graphs
#===============================================================

library(tidyverse)
library(stargazer)
library(kableExtra)

#===============================================================
# Switching Summary Statistics
#===============================================================

df <- read_csv("data.csv")

df |>
  group_by(prev_cpc_section, switch) |>
  summarise(
    count = n()
  ) |>
  ungroup() |>
  group_by(prev_cpc_section) |>
  mutate(num_patents = sum(count),
         percentage_switch = (count/num_patents)*100) |>
  filter(switch) |>
  select(-num_patents,-switch) -> a

kable(a, "latex")

rm(df,a)

#===============================================================
# CPC Patent Production
#===============================================================

df <- read_csv("cpc_section_production.csv")

df |>
  rename(`CPC Section` = cpc_section) |>
  filter(year != 2023) |>
  group_by(`CPC Section`) |>
  arrange(year) |>
  mutate(count.l1 = lag(count),
         percentage_growth = ((count - count.l1)/count)*100)-> df



ggplot(data = df, aes(x = year, y = count, color = `CPC Section`)) +
  geom_line() + 
  theme_light() +
  ylab("Number of Patents") +
  xlab("Year") +
  theme(legend.position = "top")

ggsave("num_patents.png", device = "png", width = 7, height = 5.5, units = "in")

ggplot(data = df, aes(x = year, y = percentage_growth, color = `CPC Section`)) +
  geom_line() + 
  theme_light() +
  ylab("Growth Rate %") +
  xlab("Year") +
  theme(legend.position = "top")

ggsave("percent_growth.png", device = "png", width = 7, height = 5.5, units = "in")
  

gm_mean <- function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}

df |>
  ungroup() |>
  group_by(`CPC Section`) |>
  summarise( num_patents = sum(count),
             avg_production = mean(count),
             avg_growth = gm_mean(percentage_growth/100)*100) -> a

kable(a, "latex", booktabs=T)

