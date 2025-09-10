from pydantic import BaseModel
from typing import Optional
from educhain import Educhain
from mcp.server.fastmcp import FastMCP
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()
clientkey = OpenAI()

class ContentRequest(BaseModel):
    topic: str
    num_questions: Optional[int] = 5

# instantiate an MCP server client
mcp = FastMCP("EduChanin MCP")

client = Educhain() # Deafault gpt-4o-mini Model

# Create generate-questions tool
@mcp.tool()
def generate_questions(req: ContentRequest):
    """Generate comprehension questions from a paragraph. Specify difficulty level and number of questions."""
    try:
        questions = client.qna_engine.generate_questions(topic=req.topic, num_questions=req.num_questions)
        return {"topic": req.topic, "questions": questions}
    except Exception as e:
        raise Exception(f"Something went wrong: {e}")

# Create generate_lesson_plan tool        
@mcp.tool()
def generate_lesson_plan(req: ContentRequest):
    """Generate comprehension lesson plan for a paragraph."""
    try:
        questions = client.content_engine.generate_lesson_plan(topic=req.topic)
        return {"topic": req.topic, "lesson_plan": lesson_plan}
    except Exception as e:
        raise Exception(f"Something went wrong: {e}")              
   

# Run the server if the script is executed directly
if __name__ == "__main__":  
    mcp.run()
 
