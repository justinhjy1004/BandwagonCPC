#============================================================================
# Author: Justino
#
# This script is to calculate the difference in within section production
# as compared to those outside of the section
#============================================================================

library(tidyverse)

df <- read_csv("cpc_section_production.csv")

# Obtain all relevant sections
cpc_sections <- unique(df$cpc_section)

colnames(df) <- c("classification", "year", "num_patents")

df |>
  # Start from 1980 (including 1979 for growth)
  filter(year >= 1979) |> 
  # Group by within the same classification or otherwise
  mutate(
    same_classification = ifelse(classification == cpc_sections[1], TRUE, FALSE)
  ) |>
  group_by(year, same_classification) |>
  summarise(
    num_patents = sum(num_patents)
  ) |>
  # Calculate growth of patents within the same class
  # and classifications outside
  ungroup() |>
  group_by(same_classification) |>
  mutate(
    classification = cpc_sections[1],
    num_patents.l1 = lag(num_patents),
    growth = (num_patents - num_patents.l1)/num_patents.l1
  ) |>
  select(year, classification, same_classification, growth) |>
  spread(key = same_classification, value = growth) -> d

# Loop the process and concatenate them
for ( c in cpc_sections[2:length(cpc_sections)] ) {
  df |>
    # Start from 1980 (including 1979 for growth)
    filter(year >= 1979) |> 
    # Group by within the same classification or otherwise
    mutate(
      same_classification = ifelse(classification == c, TRUE, FALSE)
    ) |>
    group_by(year, same_classification) |>
    summarise(
      num_patents = sum(num_patents)
    ) |>
    # Calculate growth of patents within the same class
    # and classifications outside
    ungroup() |>
    group_by(same_classification) |>
    mutate(
      classification = c,
      num_patents.l1 = lag(num_patents),
      growth = (num_patents - num_patents.l1)/num_patents.l1
    ) |>
    select(year, classification, same_classification, growth) |>
    spread(key = same_classification, value = growth) -> e
  
  d <- rbind(d, e)
}

# Drop 1979, and calculate difference in growth 
d |>
  drop_na() |>
  mutate( diff_growth = (`TRUE` - `FALSE`) ) -> d

write.csv(d, "cpc_diff_growth.csv", row.names = F)
