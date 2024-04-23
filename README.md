# Bandwagon

## Overview
This is the code for the simulation and analysis of the project on the Bandwagon Effect
in the context of R&D for firms. Using the USPTO data obtained from PatentsView, we 
show that firms Bandwagon to different technology categories as classified by
CPC sections.

## Methodology
- The preprocessing of the data can be found in 

```
script.sh
```

which calls various R and Python scripts to shape the data required.

- Analysis.R is the main regression analysis for the processed data called data.csv
- Simulation.R is the main simulation results for the model proposed.

## Datasets
1. Visit https://patentsview.org/download/data-download-tables
1. Download and unzip datasets g_assignee_disambiguated, g_patent, g_us_patent_citation, and g_cpc_current
1. Make sure to download all Python and R dependencies
1. Run script.sh to clean data

## Dependencies
All Python dependencies are reflected in requirements.txt.