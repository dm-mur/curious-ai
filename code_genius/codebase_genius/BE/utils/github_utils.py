# github_utils.py
import os
import git
from pathlib import Path

def clone_repo(repo_url: str) -> str:
    tmp_dir = Path("./tmp_repos") / repo_url.split("/")[-1]
    tmp_dir.mkdir(parents=True, exist_ok=True)
    git.Repo.clone_from(repo_url, tmp_dir)
    return str(tmp_dir)

def build_file_tree(repo_path: str) -> dict:
    tree = {}
    for root, dirs, files in os.walk(repo_path):
        tree[root] = files
    return tree
