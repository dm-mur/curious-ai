import streamlit as st
import requests

# FastAPI backend URL
API_URL = "http://127.0.0.1:8000/dispense_plan"

st.set_page_config(page_title="AI Drug Dispensing System", layout="wide")

st.title("💊 AI-Enhanced Drug Dispensing System")
st.markdown("### Powered by Jac + Gemini + FastAPI")

st.write("This system simulates how a clinician requests a dispensing plan "
         "from the pharmacist, based on available stock and drug data.")

if st.button("Generate Dispense Plan"):
    with st.spinner("Generating plan via Jac + Gemini..."):
        try:
            response = requests.get(API_URL)
            if response.status_code == 200:
                output = response.json().get("dispense_plan", "")
                st.success("Dispense plan generated successfully ✅")
                st.text_area("🧠 AI Output:", output, height=300)
            else:
                st.error(f"Error: {response.text}")
        except Exception as e:
            st.error(f"Connection error: {e}")
