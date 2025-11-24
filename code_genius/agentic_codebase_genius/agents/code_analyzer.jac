walker build_ccg {
    has repo_path: str;
    has output_path: str;
    has code_context_graph;

    can entry {
        report "CodeAnalyzer: Building Code Context Graph";

        # Analyze code structure via Python module
        let analysis_result = py_module.tree_parser.analyze_repository(repo_path);
        here.code_context_graph = analysis_result;

        # Save analysis results as JSON
        std.file_write(std.json_dump(analysis_result), output_path + "/code_analysis.json");

        report "CodeAnalyzer: Found " 
               + std.to_str(analysis_result.classes.length) + " classes";
    }
}
