import streamlit as st
import os
import re
from config import settings
from sqlalchemy import create_engine, text
import llm_adapter as llm
import db as db
import sql_validator as validator
import schema_rag as rag
import rag_retriever as retriever_module

# --- Load index from vector store ---
PERSIST_DIR = settings.PERSIST_DIR
DATABASE_URL = settings.DATABASE_URL

# CREATE DB ENGINE
engine = create_engine(DATABASE_URL, pool_pre_ping=True, future=True)

# BUILD DB SCHEMA
rag.build_schema_rag(engine)
table_names = rag.table_names

# --- Streamlit UI ---
st.set_page_config(page_title="Text-to-SQL Assistant", layout="wide")
st.title("🧠 Natural Language to SQL")

question = st.text_area("Ask your question:", placeholder="e.g., Top 3 highest paid employees in Engineering")

if st.button("Generate Results"):
    if not question.strip():
        st.warning("Please enter a question first.")
    else:
        with st.spinner("Retrieving data..."):
            # 1️⃣ Retrieve context
            retriever = retriever_module.get_retriever()

            # Generate Text-to-SQL
            text_to_sql_chain = llm.get_text_to_sql_chain(retriever)
            gen_sql_query = llm.get_text_to_sql_query(text_to_sql_chain, question=question)
            print("Generated SQL Query: ", gen_sql_query)

            # --- Display Results ---
            st.subheader("Query Results:")

            # Validate SQL
            if validator.is_safe_sql(gen_sql_query, table_names):
                df = db.execute_select(engine, gen_sql_query)
                st.dataframe(df, use_container_width=True)
                # Download as csv
                csv = df.to_csv(index=False).encode('utf-8')
                st.download_button("Download Results as CSV", data=csv, file_name="query_results.csv", mime="text/csv")
            else:
                print("Generated SQL is not safe to execute.")
                st.error("The generated SQL query is not safe to execute.")

else:
        st.warning("Please enter a question.")            
