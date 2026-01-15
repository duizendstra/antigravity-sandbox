import sys
import os
import re

def check_file(filepath):
    """
    Checks if a file contains print() statements.
    Returns list of (line_number, line_content) tuples.
    """
    violations = []
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            for i, line in enumerate(lines):
                # Simple check for print( - ignores comments for simplicity but could be improved
                # This is a basic example.
                if re.search(r'^\s*print\(', line) or re.search(r'[^\'"]print\(', line):
                     violations.append((i + 1, line.strip()))
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
    return violations

def main():
    if len(sys.argv) < 2:
        print("Usage: python check.py <path>")
        sys.exit(1)

    path = sys.argv[1]
    has_violations = False

    if os.path.isfile(path):
        violations = check_file(path)
        if violations:
            has_violations = True
            print(f"Violations in {path}:")
            for line_num, content in violations:
                print(f"  Line {line_num}: {content}")
    elif os.path.isdir(path):
        for root, _, files in os.walk(path):
            for file in files:
                if file.endswith('.py') and file != 'check.py':
                    filepath = os.path.join(root, file)
                    violations = check_file(filepath)
                    if violations:
                        has_violations = True
                        print(f"Violations in {filepath}:")
                        for line_num, content in violations:
                            print(f"  Line {line_num}: {content}")
    else:
        print(f"path {path} does not exist")
        sys.exit(1)

    if has_violations:
        print("\nFAILURE: print() statements found. Please use logging instead.")
        sys.exit(1)
    else:
        print("\nSUCCESS: No print() statements found.")
        sys.exit(0)

if __name__ == "__main__":
    main()
