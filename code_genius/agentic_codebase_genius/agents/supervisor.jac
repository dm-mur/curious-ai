walker start_analysis {
    has github_url: str;
    has output_path: str;
    has analysis_status: str = "not_started";

    can entry {
        # Update status
        here.analysis_status = "started";

        # Create output directory
        std.fs.mkdir(output_path, true);
        std.file_write(output_path + "/STARTED", "started");

        report "Supervisor: Starting analysis pipeline";

        # 1️⃣ Repository Mapping
        spawn here walker::clone_and_map(
            github_url=github_url,
            output_path=output_path
        );

        # 2️⃣ Code Analysis
        spawn here walker::build_ccg(
            repo_path=output_path + "/cloned_repo",
            output_path=output_path
        );

        # 3️⃣ Documentation Generation
        spawn here walker::generate_documentation(
            repo_path=output_path + "/cloned_repo",
            output_path=output_path
        );

        # Mark completion
        std.file_write(output_path + "/COMPLETED", "done");
        here.analysis_status = "completed";

        report "Supervisor: Analysis complete!";
    }
}
