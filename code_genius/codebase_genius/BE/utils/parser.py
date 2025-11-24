# Placeholder for parsing Python or Jac code
def generate_ccg(file_tree: dict) -> dict:
    """Generate a simple Code Context Graph."""
    ccg = {}
    for folder, files in file_tree.items():
        for f in files:
            if f.endswith(".py") or f.endswith(".jac"):
                ccg[f"{folder}/{f}"] = {"functions": [], "classes": []}  # Placeholder
    return ccg
