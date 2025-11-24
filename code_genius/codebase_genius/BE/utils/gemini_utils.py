import os
import openai
from dotenv import load_dotenv

load_dotenv()
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

openai.api_key = GEMINI_API_KEY

def summarize_text(text: str, max_tokens: int = 150) -> str:
    """Use Gemini API to summarize a text snippet."""
    response = openai.chat.completions.create(
        model="gpt-4.1-mini",
        messages=[{"role": "user", "content": f"Summarize this text concisely:\n{text}"}],
        max_tokens=max_tokens,
    )
    summary = response.choices[0].message.content.strip()
    return summary

def generate_doc_prose(structured_info: str, max_tokens: int = 500) -> str:
    """Use Gemini API to generate high-quality markdown prose from structured data."""
    prompt = f"Convert this structured code information into clear markdown documentation:\n{structured_info}"
    response = openai.chat.completions.create(
        model="gpt-4.1-mini",
        messages=[{"role": "user", "content": prompt}],
        max_tokens=max_tokens,
    )
    return response.choices[0].message.content.strip()
