from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import List, Dict, Any
from sqlalchemy import create_engine, text
import llm_adapter as llm
import db as db
import sql_validator as validator
from config import settings
import schema_rag as rag
import rag_retriever as retriever_module

# CONFIGURATION
app = FastAPI(title="Text-to-SQL API")
DATABASE_URL = settings.DATABASE_URL

# CREATE DB ENGINE
engine = create_engine(DATABASE_URL, pool_pre_ping=True, future=True)

# BUILD DB SCHEMA
rag.build_schema_rag(engine)
table_names = rag.table_names

# QUERY REQUEST AND RESPONSE MODELS
class QueryRequest(BaseModel):
    question: str = Field(..., description="Natural language question")

class QueryResponse(BaseModel):
    sql_query: str
    rows: List[Dict[str, Any]]
    columns: List[str]
    row_count: int

    @classmethod
    def from_db_result(cls, sql: str, result):
        rows = [dict(row) for row in result]
        columns = list(rows[0].keys()) if rows else []
        return cls(sql_query=sql, rows=rows, columns=columns, row_count=len(rows))

# MAIN ENDPOINT
@app.post("/query", response_model=QueryResponse)
def run_query(request: QueryRequest):
    try:
        # Get retriever
        retriever = retriever_module.get_retriever()

        # Generate Text-to-SQL
        text_to_sql_chain = llm.get_text_to_sql_chain(retriever)
        gen_sql_query = llm.get_text_to_sql_query(text_to_sql_chain, question=request.question)
        print("Generated SQL Query: ", gen_sql_query)

        # Validate SQL
        if not validator.is_safe_sql(gen_sql_query, table_names):
            raise HTTPException(status_code=400, detail="Unsafe SQL detected")

        # Execute query
        data = db.execute_select(engine, gen_sql_query)

        return QueryResponse.from_db_result(request.question, data)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# HEALTH CHECK
@app.get("/")
def root():
    return {"message": "Text-to-SQL API running successfully."}
