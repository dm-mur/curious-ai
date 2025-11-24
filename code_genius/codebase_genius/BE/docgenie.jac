walker DocGenie {
    can generate_docs;

    generate_docs(file_tree: dict, ccg: dict, readme_summary: str) -> str {
        # Generate diagrams from CCG
        py call diagram_gen.create_diagrams(ccg) -> diagrams;

        # Build structured information for documentation
        py call github_utils.build_structured_info(file_tree, ccg, readme_summary, diagrams) -> structured_info;

        # Generate prose using Gemini API
        py call gemini_utils.generate_doc_prose(structured_info) -> markdown_content;

        # Save the markdown locally
        py call github_utils.save_markdown(markdown_content, file_tree) -> output_path;

        return output_path;
    }
}
