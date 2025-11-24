import json

class DiagramGenerator:
    @staticmethod
    def generate_markdown(file_tree, code_analysis, output_path):
        markdown = "# Codebase Documentation\n\n"
        
        # Project Overview
        markdown += "## Project Overview\n\n"
        markdown += f"This repository contains {len(file_tree['files'])} files "
        markdown += f"with {len(code_analysis['classes'])} classes "
        markdown += f"and {len(code_analysis['functions'])} functions.\n\n"
        
        # File Structure
        markdown += "## File Structure\n\n```\n"
        for file in file_tree['files'][:20]:  # Show first 20 files
            markdown += f"{file['path']}\n"
        markdown += "```\n\n"
        
        # API Reference
        markdown += "## API Reference\n\n"
        
        for cls in code_analysis['classes']:
            markdown += f"### {cls['name']}\n\n"
            markdown += f"**File:** {cls['file']}\n\n"
            markdown += "**Methods:**\n"
            for method in cls['methods']:
                markdown += f"- `{method}()`\n"
            markdown += "\n"
        
        return markdown