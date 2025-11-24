import ast
import os

class TreeParser:
    @staticmethod
    def analyze_repository(repo_path):
        analysis = {
            "classes": [],
            "functions": [],
            "imports": [],
            "file_count": 0
        }
        
        for root, dirs, files in os.walk(repo_path):
            for file in files:
                if file.endswith('.py'):
                    file_path = os.path.join(root, file)
                    analysis["file_count"] += 1
                    
                    try:
                        with open(file_path, 'r', encoding='utf-8') as f:
                            code = f.read()
                        
                        tree = ast.parse(code)
                        
                        # Extract classes and functions
                        for node in ast.walk(tree):
                            if isinstance(node, ast.ClassDef):
                                analysis["classes"].append({
                                    "name": node.name,
                                    "file": file_path,
                                    "methods": [n.name for n in node.body if isinstance(n, ast.FunctionDef)]
                                })
                            elif isinstance(node, ast.FunctionDef):
                                analysis["functions"].append({
                                    "name": node.name,
                                    "file": file_path,
                                    "args": [arg.arg for arg in node.args.args]
                                })
                    except:
                        continue
        
        return analysis