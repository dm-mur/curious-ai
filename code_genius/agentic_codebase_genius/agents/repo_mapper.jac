walker clone_and_map {
    has github_url: str;
    has output_path: str;
    has file_tree;
    has readme_summary: str = "";

    can entry {
        report "RepoMapper: Cloning repository " + github_url;

        // Clone repo via Python module
        let repo_path = py_module.git_utils.clone_repo(github_url, output_path);

        // Generate file tree
        here.file_tree = py_module.git_utils.generate_file_tree(repo_path);

        // Save file tree as JSON
        std.file_write(std.json_dump(here.file_tree), output_path + "/file_tree.json");

        // Optionally summarize README using ByLLM
        let readme_path = repo_path + "/README.md";
        if std.fs.exists(readme_path) {
            let readme_content = std.file_read(readme_path);
            here.readme_summary = byllm.prompt("Summarize the following README:\n" + readme_content);
            std.file_write(here.readme_summary, output_path + "/readme_summary.md");
        }

        report "RepoMapper: Generated file tree with " 
               + std.to_str(here.file_tree.files.length) + " files";
    }
}
