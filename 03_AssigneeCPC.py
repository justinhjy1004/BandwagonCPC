import polars as pl

"""
Author: Justino

This script is mainly to join the CPC classification and Assignees Portfolio
We also have a comprehensive list of the patents produced in each year
"""
if __name__ == '__main__':

    # Read the files on CPC classification and Assignees Portfolio
    df = pl.read_csv("assignee_portfolio.csv")
    cpc = pl.read_csv("patent_cpc.csv")

    # Cast "patent_id" to the same data types for compatability
    cpc = cpc.with_columns(pl.col("patent_id").cast(pl.Utf8))
    df = df.with_columns(pl.col("patent_id").cast(pl.Utf8))

    # Inner join CPC class with assignee portfolio
    df = df.join(cpc, on = "patent_id", how = "inner")

    # Sort Assignees and Date (mainly for visualization)
    df = df.with_columns(pl.col('date').str.to_date(r"%Y-%m-%d"))
    df = df.sort(by = ["assignee_id", "date"])

    # Since we only care about the year
    df = df.with_columns(pl.col("date").dt.year().alias("year"))

    # We want to know the production in each CPC class per year
    cpc_production = df.group_by(["cpc_section", "year"]).count()
    cpc_production.write_csv("cpc_section_production.csv")

    # Looking at the previous CPC section to analyze if the firm "switches"
    df = df.with_columns(
        pl.col('cpc_section').shift().over('assignee_id').alias('prev_cpc_section')
    )

    # Looking at the previous patent to analyze to match the "previous citations"
    df = df.with_columns(
        pl.col('patent_id').shift().over('assignee_id').alias('prev_patent_id')
    )

    df.write_csv("assignee_portfolio.csv")