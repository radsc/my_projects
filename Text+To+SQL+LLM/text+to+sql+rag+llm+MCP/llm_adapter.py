from langchain_core.prompts import PromptTemplate
from langchain_ollama import ChatOllama
from langchain_classic.chains import RetrievalQA
from config import settings
import json


MODEL = settings.MODEL

def get_text_to_sql_chain(retriever):
    llm = ChatOllama(model=MODEL, temperature=0)
    prompt = PromptTemplate(
        input_variables=["context", "question"],
        template=(
            "You are an expert data analyst. Use the database schema below to write an accurate MySQL query.\n\n"
            "Schema:\n{context}\n\n"
            "Question:\n{question}\n\n"
            "Return ONLY the SQL query, no explanation."
        )
    )
    # Chain = Retrieval (RAG) + Prompt + LLM
    chain = RetrievalQA.from_chain_type(
        llm=llm,
        retriever=retriever,
        chain_type="stuff",
        chain_type_kwargs={"prompt": prompt},
        return_source_documents=True,
    )
    return chain

def get_text_to_sql_query(chain, question):
    result = chain.invoke({"query": question})
    gen_sql_query = result['result'].replace("`", "").replace("\n", " ").replace("sql", "").strip()
    return gen_sql_query
