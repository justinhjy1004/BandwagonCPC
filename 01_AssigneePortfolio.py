import polars as pl
from datetime import date, datetime
from credentials import uri

"""
Author: Justino

This scripts constructs the patent assignees "portfolio",
that is for every matched assignee, we have the patent
they own and the corresponding dates and information
"""

if __name__ == '__main__':

    # Query from database to join the patent dataset and the assignee dataset
    query = """

    SELECT patents.patent_id AS patent_id, patent_date AS date,  assignee_id
    FROM patents 
    INNER JOIN assignee 
    ON patents.patent_id = assignee.patent_id
    WHERE patent_date >= '1979-01-01'

    """

    df = pl.read_database_uri(query=query, uri=uri)
    
    # Sort by assignees and date
    df = df.sort(["assignee_id", "date"])

    # Count the number of patents each assignee has
    df = df.with_columns(
        pl.col("assignee_id").count().over('assignee_id').alias("num_patents")
    )

    # Write file under assignee portfolio
    df.write_csv("assignee_portfolio.csv")