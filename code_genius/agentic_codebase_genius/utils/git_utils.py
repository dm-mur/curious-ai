import os
import subprocess
import json
from pathlib import Path

class GitUtils:
    @staticmethod
    def clone_repo(github_url, output_path):
        repo_dir = os.path.join(output_path, "cloned_repo")
        
        try:
            result = subprocess.run(
                ["git", "clone", github_url, repo_dir],
                capture_output=True, text=True
            )
            return repo_dir if result.returncode == 0 else None
        except Exception as e:
            print(f"Clone error: {e}")
            return None
    
    @staticmethod
    def generate_file_tree(repo_path):
        tree = {"files": [], "directories": []}
        
        for root, dirs, files in os.walk(repo_path):
            # Skip hidden directories
            dirs[:] = [d for d in dirs if not d.startswith('.')]
            
            for file in files:
                if not file.startswith('.'):
                    rel_path = os.path.relpath(os.path.join(root, file), repo_path)
                    tree["files"].append({
                        "name": file,
                        "path": rel_path,
                        "size": os.path.getsize(os.path.join(root, file))
                    })
        
        return tree