import polars as pl

"""
Author: Justino

This script is to assign a CPC classification to a given
patent. This is required since a patent can be assigned to
multiple CPC classes and hence we choose the most frequently 
mentioned CPC class for a given patent.

We break ties arbitrarily for those with two or more 'highest'
counts of CPC classes.
"""

if __name__ == '__main__':

    # Read CPC classification data from PatentsView
    df = pl.read_csv("g_cpc_current.tsv", separator="\t")

    # Count the CPC sections assigned to the patent
    df = df.group_by(["patent_id", "cpc_section"]).agg(
            pl.col('cpc_subclass').count().alias("count")
        )
    
    # Get the CPC section with the highest count (since we want to assign)
    # each patent to one class
    df = df.with_columns(
            pl.col("count").max().over("patent_id").alias("max_count")
        ).sort(["patent_id", "cpc_section"])
    
    # And filter those that are not the max
    df = df.filter(pl.col("count") == pl.col("max_count"))

    # We break ties arbitrarily for those with multiple MAX
    df = df.filter(
        pl.int_range(0, pl.count()).shuffle().over("patent_id") == 0
    )

    # Select only relevant columns and save them
    df = df.select(["patent_id", "cpc_section"])

    df.write_csv("patent_cpc.csv")