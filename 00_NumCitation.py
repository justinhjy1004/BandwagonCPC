import polars as pl

"""
Author: Justino

Counts the number of citation a given patent received
"""

if __name__ == '__main__':
    ## Read datasets of all US patents' citation
    df = pl.read_csv("g_us_patent_citation.tsv", separator="\t", infer_schema_length=0)

    ## Select relevant columns and count them
    df = df.select(["citation_patent_id", "patent_id"])
    df = df.group_by("citation_patent_id").count()

    ## Rename for convenience
    df.columns = ["citation_patent_id", "num_citation"]

    df.write_csv("num_citation.csv")