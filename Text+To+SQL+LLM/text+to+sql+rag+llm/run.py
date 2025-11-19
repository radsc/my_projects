# ---------------------------
# Quick runnable example
# ---------------------------
# from typing import List, Dict, Any
from sqlalchemy import create_engine, text
import llm_adapter_ollama as llm
import db as db
import sql_validator as validator
from config import settings
import schema_rag as rag
import rag_retriever as retriever_module

DATABASE_URL = settings.DATABASE_URL
engine = create_engine(DATABASE_URL, pool_pre_ping=True, future=True)
rag.build_schema_rag(engine)
table_names = rag.table_names
print("Tables in DB:", table_names)

if __name__ == "__main__":

    # nl = "List employees with salary greater than 55000"
    # question = "Top 3 highest paid employee names in Engineering"
    question = "department wise average salary"
    print("Question:", question)

    try:
        retriever = retriever_module.get_retriever()
        docs = retriever.invoke(question)
        context = "\n".join([doc.page_content for doc in docs])
        print("Retrieved Context:\n", context)

        # # Generate Text-to-SQL
        text_to_sql_chain = llm.get_text_to_sql_chain(context, question)
        # gen_sql_query = llm.get_text_to_sql_query(text_to_sql_chain, question=question)
        print("Generated SQL:\n", text_to_sql_chain)
        if validator.is_safe_sql(text_to_sql_chain, table_names):
            results = db.execute_select(engine, text_to_sql_chain)
            print("Query Results:")
            for row in results:
                print(row)
        else:
            print("Generated SQL is not safe to execute.")        
    except Exception as e:
        print("Error:", e)
