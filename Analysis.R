#===============================================================
# Author: Justino
#
# Analysis of the bandwagon effect
#===============================================================

library(tidyverse)
library(stargazer)

df <- read_csv("data.csv")

# Vanilla Regression
lmod <- lm(switch ~ diff_growth + log1p(num_citation), df)
summary(lmod)

#===============================================================
# Regression by Number of Patents
#===============================================================

# Classify the assignee has having the top 25% in number of patents
# or bottom 75%
df |>
  select(assignee_id, num_patents) |>
  distinct() -> a

top_25_patent <- quantile(a$num_patents)[[4]]

df |>
  mutate(top_25_patent = ifelse(num_patents > top_25_patent, T, F)) -> df

# Regression Estimates on the bottom 75% 
lmod <- lm(switch ~ diff_growth + log1p(num_citation), df[!df$top_25_patent,])
summary(lmod)

# Regression Estimates on the top 25% 
lmod <- lm(switch ~ diff_growth + log1p(num_citation), df[df$top_25_patent,])
summary(lmod)

# Regression Estimates on interaction
lmod <- lm(switch ~ diff_growth + log1p(num_citation)*top_25_patent, df)
summary(lmod)

#===============================================================
# Regression by Number of Citations Received
#===============================================================

# Count the number of total citations received
 df |>
   select(assignee_id, num_citation) |>
   group_by(assignee_id) |>
   summarise(citation_received = sum(num_citation)) -> c

# Get the top 25% of citation receipients
top_25_citation <- quantile(c$citation_received)[[4]]

c |>
  mutate(top_citation = ifelse(citation_received > top_25_citation, T, F)) -> c

top_25_producers <- c[c$top_citation,]$assignee_id

# Classify them if they are top of not
df |>
  mutate(top_25_citation = ifelse(assignee_id %in% top_25_producers, T, F)) -> df

# Regression Estimates on the top 25% 
lmod <- lm(switch ~ diff_growth + log1p(num_citation), df[df$assignee_id %in% top_25_producers,])
summary(lmod)

# Regression Estimates on the bottom 75% 
lmod <- lm(switch ~ diff_growth + log1p(num_citation), df[!(df$assignee_id %in% top_25_producers),])
summary(lmod)

# Regression Estimates on the interaction
lmod <- lm(switch ~ diff_growth + log1p(num_citation)*top_25_citation, df)
summary(lmod)
