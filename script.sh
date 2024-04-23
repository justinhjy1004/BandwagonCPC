#!/bin/bash  

echo "Get count of citations!"
python3 00_NumCitation.py

echo "Matching Assignees and Patents!"
python3 01_AssigneePortfolio.py

echo "CPC Classifications for the Patents"
python3 02_CPC.py

echo "Joining CPC with Assignee Portfolio"
python3 03_AssigneeCPC.py

echo "Calculating CPC over the years"
Rscript 04_class_growth.R

echo "Merge all to get our analyzable data"
python3 05_GrowthAndSwitch.py 5

echo "And we are done!"