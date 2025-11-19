from pydantic import BaseModel
from mcp.server.fastmcp import FastMCP
from dotenv import load_dotenv
from sqlalchemy import create_engine
import llm_adapter as llm
import db as db
import sql_validator as validator
import schema_rag as rag
import rag_retriever as retriever_module
import os
import json

load_dotenv()

PERSIST_DIR = os.getenv("PERSIST_DIR")
DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_engine(DATABASE_URL, pool_pre_ping=True, future=True) # Create DB engine
rag.build_schema_rag(engine) # Build DB schema RAG
table_names = rag.table_names

class ContentRequest(BaseModel):
    question: str

mcp = FastMCP("Text to SQL")  # Instantiate MCP server client

@mcp.tool()
def generate_text_sql_results(req: ContentRequest):
    """Execute Text-to-SQL query and return database results as table like spreadsheeet."""
    print("TOOL CALLED! question=", req.question)
    try:
        retriever = retriever_module.get_retriever() # Retrieve context
        text_to_sql_chain = llm.get_text_to_sql_chain(retriever)
        gen_sql_query = llm.get_text_to_sql_query(text_to_sql_chain, question=req.question)
        print("Generated SQL Query: ", gen_sql_query)

        if validator.is_safe_sql(gen_sql_query, table_names):
                rows = db.execute_select(engine, gen_sql_query)
                print("Query Results: ", rows)
               
        else:
            print("Generated SQL is not safe to execute.")
            raise Exception("Generated SQL is not safe to execute.")        
    #     return {
    #     "content": [
    #         {
    #             "type": "json",
    #             "json": rows
    #         }
    #     ]
    # }
        return [
            {"type": "json",
            "json": rows
            }
        ]

    except Exception as e:
        raise {
            "content": [
                { "type": "text", "text": f"Error: {str(e)}" }
            ],
            "isError": True
        }
    
if __name__ == "__main__":
    mcp.run()   