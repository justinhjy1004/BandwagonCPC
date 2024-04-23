import polars as pl
from datetime import date, datetime

"""
Author: Justino

This scripts constructs the patent assignees "portfolio",
that is for every matched assignee, we have the patent
they own and the corresponding dates and information
"""

if __name__ == '__main__':

    p = pl.read_csv("g_patent.tsv", separator="\t", infer_schema_length = 0).select(["patent_id", "patent_date"])
    a = pl.read_csv("g_assignee_disambiguated.tsv", separator="\t", infer_schema_length = 0).select(["patent_id", "assignee_id"])

    df = p.join(a, on = "patent_id", how = "inner")
    df.columns = ['patent_id', 'date', 'assignee_id']
    
    # Sort by assignees and date
    df = df.sort(["assignee_id", "date"])

    # Count the number of patents each assignee has
    df = df.with_columns(
        pl.col("assignee_id").count().over('assignee_id').alias("num_patents")
    )

    # Write file under assignee portfolio
    df.write_csv("assignee_portfolio.csv")