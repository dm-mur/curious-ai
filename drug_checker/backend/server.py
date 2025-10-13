from fastapi import FastAPI
from dotenv import load_dotenv
import subprocess
import os

load_dotenv()

app = FastAPI(title="AI Drug Dispensing Backend")

@app.get("/dispense_plan")
def get_dispense_plan():
    try:
        # Run your Jac script using the system-installed Jac CLI
        result = subprocess.run(
            ["jac", "run", "backend/drug_checker.jac"],
            capture_output=True,
            text=True
        )

        if result.returncode != 0:
            return {"error": result.stderr}

        # Extract only the dispense plan from printed output
        output = result.stdout.strip()
        return {"dispense_plan": output}

    except Exception as e:
        return {"error": str(e)}
