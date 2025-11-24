walker CodeAnalyzer {
    action build_ccg(file_tree: dict) -> dict {
        py call parser.generate_ccg(file_tree) -> ccg;
        return ccg;
    }
}

