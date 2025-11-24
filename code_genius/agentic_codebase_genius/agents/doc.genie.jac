walker generate_documentation {
    has repo_path: str;
    has output_path: str;
    has documentation_content: str = "";

    can entry {
        report "DocGenie: Generating documentation";

        # Load analysis results
        let file_tree = std.json_load(std.file_read(output_path + "/file_tree.json"));
        let code_analysis = std.json_load(std.file_read(output_path + "/code_analysis.json"));

        # Generate markdown documentation via Python module
        let markdown = py_module.diagram_generator.generate_markdown(
            file_tree, code_analysis, output_path
        );

        # Optional: enrich with LLM summary
        let summary = byllm.prompt(
            "Generate a high-level summary of this codebase documentation:\n" + markdown
        );
        markdown = markdown + "\n\n# Summary\n" + summary;

        # Save documentation
        std.file_write(markdown, output_path + "/documentation.md");
        here.documentation_content = markdown;

        report "DocGenie: Documentation generated successfully!";
    }
}
