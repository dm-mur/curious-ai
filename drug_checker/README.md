---

# 💊 AI-Driven Drug Dispensing System (Jac + ByLLM + Gemini)

This project demonstrates how to build an **AI-enhanced drug dispensing system** using **Jac** (for modeling entities and workflows) and **ByLLM** (for integrating Large Language Models like Google Gemini).

It models a **pharmacy workflow** where information flows from a warehouse (drug stock and availability) to a pharmacist, who then uses **AI reasoning** to generate a **dispensing plan** for clinicians.

---

## 🌟 Key Highlights

* **Warehouse Modeling**

  * Track drug availability (`Drug` node).
  * Maintain stock records (`BinCard` node).

* **Pharmacist + AI**

  * Collects warehouse info.
  * Uses **Gemini 2.5 Flash** to plan dispensing based on stock and availability.

* **Walkers (Agents)**

  * `StoreManager` → Collects stock data, queries the LLM.
  * `ClinicianWalker` → Runs the full pipeline and prints the dispensing plan.

* **LLM Integration**
  The function `create_dispense_plan` is bound directly to the Gemini model, making the plan **context-aware and human-readable**.

---

## 📂 Project Structure

```
.
├── main.jac        # Core Jac code (nodes, walkers, entrypoint)
└── README.md       # Documentation
```

### Code Flow

1. **Nodes**

   * `Drug`: Tracks availability of individual drugs.
   * `BinCard`: Maintains stock list.
   * `Pharmacist`: Works with AI to design a dispensing plan.

2. **Walkers**

   * `StoreManager`: Traverses warehouse, gathers stock info, and invokes AI planning.
   * `ClinicianWalker`: Calls `StoreManager`, collects outputs, and finalizes the plan.

3. **AI Binding**

```python
def create_dispense_plan(gear: dict) -> str by llm();
```

This binds the function to the Gemini model (`by llm()`), enabling **natural language plan generation**.

---

## 🚀 Getting Started

### 1. Install Dependencies

Ensure you have Jac and ByLLM installed:

```bash
pip install jac byllm
```

### 2. Set Your API Key

Replace the placeholder in the code:

```python
glob llm = Model(
    model_name="gemini/gemini-2.5-flash",
    api_key="YOUR_API_KEY"
);
```

Or set as an environment variable:

```bash
export GEMINI_API_KEY="your_api_key_here"
```

### 3. Run the Program

```bash
jac run main.jac
```

---

## 📊 Sample Run

### Input (Defined in Code)

* Drugs available: ✅ Aspirin, Ibuprofen, Paracetamol
* Pharmacist node present
* LLM enabled with Gemini

### Console Output

```text
My Dispense Plan:
Dispensing Plan for Clinician

Available drugs: aspirin, ibuprofen, paracetamol
Status: All marked as available ✅

Recommended dispensing approach:
- Aspirin: Dispense for mild pain and fever cases. Stock adequate.
- Ibuprofen: Dispense for inflammation and pain management. Monitor daily usage to avoid stock-out.
- Paracetamol: Primary first-line analgesic. Dispense broadly for mild fever/pain. Reserve backup stock.

Note: If demand increases, prioritize Paracetamol and Ibuprofen as first-line options.
```

💡 The exact plan will vary depending on **AI outputs** and the **input stock configuration**.

---

## 🔮 Possible Extensions

* **Add quantities** to drugs (not just availability).
* **Track expiry dates** for safer dispensing.
* **Connect to real databases** (e.g., hospital inventory systems).
* **Add multi-level workflows** (Central Warehouse → Hospital Store → Pharmacy → Patient).
* **Introduce alerts** for low stock or near-expiry drugs.

---

## ⚡ Tech Stack

* **Jac** → Declarative language for graph-based reasoning & AI workflows.
* **ByLLM** → Middleware for connecting Jac to LLMs.
* **Gemini 2.5 Flash** → Google’s fast reasoning model for plan generation.

---

## 📝 License

MIT License – Free to use, modify, and distribute.

---