import streamlit as st
import requests

st.title("Codebase Genius")

repo_url = st.text_input("Enter GitHub Repository URL")

if st.button("Generate Docs"):
    response = requests.post("http://127.0.0.1:8000/generate_docs", json={"repo_url": repo_url})
    if response.status_code == 200:
        st.success("Documentation generated!")
        st.write(response.json())
    else:
        st.error("Failed to generate documentation")
