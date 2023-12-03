import polars as pl
import sys


if __name__ == "__main__":

    # The year the decision is "made" to produce the patent
    n = int(sys.argv[1])
    df = pl.read_csv("assignee_portfolio.csv")

    # Get previous patent id for matching to citation data
    df = df.with_columns(
        pl.col('patent_id').shift().over('assignee_id').alias('prev_patent_id')
    )

    # Check if they remain in the same CPC section
    # and label if they switched or not
    df = df.with_columns( pl.when(pl.col("cpc_section") == pl.col("prev_cpc_section"))
                            .then(False).otherwise(True).alias("switch") ) 

    df = df.with_columns( (pl.col("year") - n).alias("year_decided") )

    # Remove the first patent (since we cannot observe switches)
    df = df.filter(
        ~pl.col('prev_cpc_section').is_null()
    )

    # Read in file on CPC growth
    cpc = pl.read_csv("cpc_diff_growth.csv")

    # We join the CPC growth based on the year the firm decided to 
    # switch and pursue the project
    cpc = cpc.select(["year", "classification", "diff_growth"])
    cpc.columns = ["year_decided", "cpc_section", "diff_growth"]
    df = df.join(cpc, how="left", on = ["year_decided", "cpc_section"])

    # Get citation data and join it with the previous citation
    # for a way to analyze the existence of "negative selection"
    citation = pl.read_csv("num_citation.csv", infer_schema_length = 0)
    citation.columns = ["prev_patent_id", "num_citation"]
    df = df.with_columns(pl.col("prev_patent_id").cast(pl.Utf8))
    df = df.join(citation, how="left", on = "prev_patent_id")

    # Those with null (never cited) are treated as 0
    df = df.with_columns(pl.col("num_citation").fill_null(0))
    df = df.with_columns(pl.col("num_citation").cast(pl.Int64))

    df.write_csv("data.csv")