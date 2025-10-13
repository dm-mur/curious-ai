---

# 💊 AI-Driven Drug Dispensing System 
(Jac + ByLLM + Gemini + FastAPI + Streamlit)

An intelligent **pharmacy workflow automation system** powered by **Jac**, **ByLLM**, and **Google Gemini**.
This project demonstrates how **AI reasoning** can support **drug dispensing decisions** through a fully functional pipeline that integrates **LLM intelligence**, **graph-based modeling**, and **a real-time frontend**.

---

## 🌟 Overview

The system simulates how a **pharmacist** collaborates with an **AI assistant** to design context-aware dispensing plans based on **warehouse stock data**.
It connects a **Jac reasoning engine** to a **FastAPI backend** and a **Streamlit frontend**, producing an interactive and explainable decision workflow.

---

## 🧠 Core Workflow

1. **Warehouse Data (Jac Nodes)**

   * `Drug` → Tracks drug availability.
   * `BinCard` → Maintains stock and records.

2. **AI Reasoning (ByLLM + Gemini)**

   * The `create_dispense_plan` function is bound to **Google Gemini 2.5 Flash**, generating context-aware, human-readable dispensing plans.

3. **Agents / Walkers**

   * `StoreManager` → Gathers warehouse stock and queries the AI model.
   * `ClinicianWalker` → Runs the full pipeline and prints the dispensing plan.

4. **Backend API (FastAPI)**

   * Runs the Jac logic dynamically through `/dispense_plan`.

5. **Frontend (Streamlit)**

   * Displays the AI-generated plan with a clean UI for clinicians.

---

## 📂 Project Structure

```
.
├── backend/
│   ├── server.py              # FastAPI backend
│   └── drug_checker.jac       # Jac logic for warehouse & AI reasoning
├── frontend/
│   └── app.py                 # Streamlit interface
├── requirements.txt
└── README.md
```

---

## 🚀 Quick Start

### 1. Install Dependencies

```bash
pip install jac byllm fastapi uvicorn streamlit
```

### 2. Configure Your Gemini API Key

Set as an environment variable:

```bash
export GEMINI_API_KEY="your_api_key_here"
```

Or edit the Jac file directly:

```python
glob llm = Model(model_name="gemini/gemini-2.5-flash", api_key="YOUR_API_KEY");
```

### 3. Run the Backend

```bash
uvicorn backend.server:app --reload
```

### 4. Run the Frontend

```bash
streamlit run frontend/app.py
```

Then open the link (usually `http://localhost:8501`) to access the dashboard.

---

## 🧩 Example Output

```text
Dispensing Plan for Clinician

Available drugs: Aspirin, Ibuprofen, Paracetamol
Status: All available ✅

Recommended dispensing approach:
- Aspirin: Dispense for mild pain and fever.
- Ibuprofen: For inflammation and pain management.
- Paracetamol: First-line analgesic; reserve backup stock.

Note: Prioritize Paracetamol and Ibuprofen if supply tightens.
```

The plan is dynamically generated — every run may differ depending on AI reasoning and stock data.

---

## 🔮 Future Enhancements

| Feature                 | Description                                 |
| ----------------------- | ------------------------------------------- |
| 💾 Database Integration | Connect warehouse data to SQL or DHIS2 APIs |
| ⏳ Expiry Tracking       | Include drug expiry dates for better safety |
| ⚙️ Multi-Level Workflow | Central → Regional → Facility dispensing    |
| 🚨 Smart Alerts         | Notify low-stock or soon-to-expire drugs    |
| 📈 Analytics Dashboard  | Show real-time dispensing insights          |

---

## ⚡ Tech Stack

| Layer               | Technology                  |
| ------------------- | --------------------------- |
| 🧬 Reasoning Engine | **Jac**                     |
| 🤖 LLM Bridge       | **ByLLM**                   |
| 🧠 AI Model         | **Google Gemini 2.5 Flash** |
| ⚙️ API Server       | **FastAPI**                 |
| 💻 Frontend         | **Streamlit**               |

---

## 🧪 Design Philosophy

> “Pharmacy automation should be **intelligent, explainable, and adaptive**.”
> This project bridges **human expertise** and **AI reasoning**, showing how Jac’s graph-based model can make complex workflows both interpretable and scalable.

---

## 📝 License

**MIT License** – Free to use, modify, and distribute.
© 2025 Doris Muriungi

---
