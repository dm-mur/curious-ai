walker RepoMapper {
    can map_repo;
    can summarize_readme;

    map_repo(repo_url: str) -> dict {
        py call github_utils.clone_repo(repo_url) -> repo_path;
        py call github_utils.build_file_tree(repo_path) -> tree;
        return tree;
    }

    summarize_readme(repo_url: str) -> str {
        py call github_utils.summarize_readme(repo_url) -> raw_summary;
        py call gemini_utils.summarize_text(raw_summary) -> summary;
        return summary;
    }
}
