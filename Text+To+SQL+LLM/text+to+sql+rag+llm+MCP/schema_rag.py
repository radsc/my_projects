from langchain_chroma import Chroma
from langchain_community.embeddings import SentenceTransformerEmbeddings
from config import settings
from sqlalchemy import text

EMBEDDING_MODEL = settings.EMBEDDING_MODEL
PERSIST_DIR = settings.PERSIST_DIR

table_names = []

def build_schema_rag( engine, persist_dir=PERSIST_DIR):
    global table_names
    """Extract schema from MySQL and embed into Chroma using LangChain."""
    embedding_model = SentenceTransformerEmbeddings(model_name=EMBEDDING_MODEL)
    vectorstore = Chroma(collection_name="schema_context", embedding_function=embedding_model, persist_directory=persist_dir)

    with engine.connect() as conn:
        tables = conn.execute(text("SHOW TABLES")).fetchall()
        table_names = [t[0] for t in tables]        
        docs = []
        for (table,) in tables:
            cols = conn.execute(text((f"SHOW COLUMNS FROM {table}"))).fetchall()
            col_names = [c[0] for c in cols]
            schema_text = f"Table {table} has columns: {', '.join(col_names)}"
            docs.append(schema_text)

    vectorstore.add_texts(docs)
    # vectorstore.persist()
    print(f"Stored {len(docs)} schema entries in Chroma vector store.")

    return vectorstore
