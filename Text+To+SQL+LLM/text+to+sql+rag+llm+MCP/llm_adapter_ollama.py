from langchain_core.prompts import PromptTemplate
# from langchain_community.llms import Ollama
from langchain_ollama import OllamaLLM
from langchain_classic.chains import RetrievalQA
from config import settings
import json


# MODEL = settings.MODEL
# MODEL = "defog/sqlcoder-7b-2"
MODEL = 'pxlksr/defog_sqlcoder-7b-2:Q4_K'

def get_text_to_sql_chain(context, question):
    llm = OllamaLLM(model=MODEL)
    # prompt = """
    #     You are an expert data analyst. Use the database schema below to write an accurate MySQL query.
    #     Schema:
    #     employees(id, name, department, salary)

    #     Question: What is the average salary per department?
    #     SQL:
    #     """
    prompt = """You are an expert data analyst. Use the database schema below to write an accurate MySQL query.\n\n
            Schema:\n{schema}\n\n
            Question:\n{question}\n\n
            Return ONLY the SQL query, no explanation.
            """
    response = llm.invoke(prompt)
    print('llm response', response)
    # prompt = PromptTemplate(
    #     input_variables=["context", "question"],
    #     template=(
    #         "You are an expert data analyst. Use the database schema below to write an accurate MySQL query.\n\n"
    #         "Schema:\n{context}\n\n"
    #         "Question:\n{question}\n\n"
    #         "Return ONLY the SQL query, no explanation."
    #     )
    # )

    query = llm.invoke(prompt.format(schema=context, question=question))
    print('llm response', query)
    # Chain = Retrieval (RAG) + Prompt + LLM
    # chain = RetrievalQA.from_chain_type(
    #     llm=llm,
    #     retriever=retriever,
    #     chain_type="stuff",
    #     chain_type_kwargs={"prompt": prompt},
    #     return_source_documents=True,
    # )
    return query

def get_text_to_sql_query(chain, question):
    result = chain.invoke({"query": question})
    gen_sql_query = result['result'].replace("`", "").replace("\n", " ").replace("sql", "").strip()
    return gen_sql_query