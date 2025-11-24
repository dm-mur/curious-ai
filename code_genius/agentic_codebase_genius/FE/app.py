import streamlit as st
import requests
import time

def main():
    st.title("🧠 Codebase Genius")
    st.markdown("Automatically generate documentation for any GitHub repository")
    
    github_url = st.text_input("GitHub Repository URL")
    
    if st.button("Analyze Repository"):
        if github_url:
            with st.spinner("Analyzing repository..."):
                # Call Jac service
                response = requests.post(
                    "http://localhost:8080/api_analyze",
                    json={"github_url": github_url}
                )
                
                if response.status_code == 200:
                    analysis_id = response.json()["analysis_id"]
                    
                    # Poll for completion
                    while True:
                        status_response = requests.get(
                            f"http://localhost:8080/api_get_status",
                            params={"analysis_id": analysis_id}
                        )
                        
                        if status_response.json()["status"] == "completed":
                            docs = status_response.json()["documentation"]
                            st.success("Analysis Complete!")
                            st.download_button(
                                "Download Documentation",
                                docs,
                                file_name="documentation.md"
                            )
                            st.markdown(docs)
                            break
                        time.sleep(2)
        else:
            st.error("Please enter a GitHub URL")

if __name__ == "__main__":
    main()