from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from config import settings
import pandas as pd

def execute_select(engine, sql: str, params: dict = None, limit: int = 500):
    # if "limit" not in sql.lower():
    #     sql = f"SELECT * FROM {sql} AS _q LIMIT {limit}"
    try:
        with engine.connect() as conn:
            result = conn.execute(text(sql), params or {})
            columns = result.keys()
            rows = [dict(zip(columns, r)) for r in result.fetchall()]
            # rows = result.fetchall()
            df = pd.DataFrame(rows, columns=columns)
        return rows
    except SQLAlchemyError as e:
        raise RuntimeError(f"Database query failed: {e}")