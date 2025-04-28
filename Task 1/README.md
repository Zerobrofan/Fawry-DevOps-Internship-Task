# mygrep - A Simple Grep Clone

This is a mini version of the `grep` command implemented as a bash script. It allows you to search for text patterns within files with some basic command-line options.

## Features

- Case-insensitive string searching
- Line number display option (`-n`)
- Inverted matching option (`-v`)
- Combined option support (e.g., `-vn`, `-nv`)
- Help information (`--help`)
- Error handling for invalid inputs

## Usage

```bash
./mygrep.sh [OPTIONS] PATTERN FILE
```

### Examples

```bash
# Basic search
./mygrep.sh hello testfile.txt

# Show line numbers for matches
./mygrep.sh -n hello testfile.txt

# Invert the match (show non-matching lines)
./mygrep.sh -v hello testfile.txt

# Show line numbers for inverted matches
./mygrep.sh -vn hello testfile.txt

# Display help
./mygrep.sh --help
```

## How the Script Handles Arguments and Options

1. **Option Parsing**: The script uses a simple while loop to process command-line arguments one by one. It checks for `-n`, `-v`, and `-nv/-vn` flags, setting boolean variables accordingly.

2. **Argument Handling**: After processing flags, it assigns the next arguments to `pattern` and `file` variables. It also handles errors for missing pattern or file, as well as non-existent files.

3. **Pattern Matching**: The script reads the file line by line and performs case-insensitive matching by converting both the line and pattern to lowercase before comparison.

4. **Line Number Display**: If the `-n` flag is set, it prefixes each matching line with its line number.

5. **Inverted Match**: If the `-v` flag is set, it outputs lines that do not match the pattern.

## Extending the Script

To support regex or additional options like `-i` (case-insensitive), `-c` (count matches), or `-l` (list filenames only):

1. **Regex Support**: I would replace the simple string matching with proper regex matching using `grep` or `sed` within the script, or implement pattern matching using bash's regex capabilities with `=~` operator.

2. **Additional Options**: I would extend the option parsing section to handle new flags:
   * `-i`: Would be redundant in our current implementation since it's already case-insensitive
   * `-c`: Would require a counter variable instead of printing lines
   * `-l`: Would require changing the output to just print the filename once if any match is found

3. **Structure Changes**: I'd need to modify:
   * The argument parsing section to recognize new options
   * Add new boolean flags or variables for each option
   * Modify the file processing logic to handle the different output formats
   * Update the `--help` information

## Hardest Part to Implement

The most challenging part would be properly handling combined options (like `-vn`) and ensuring they work correctly in all combinations. Getting the logic right for inverted matches while also considering other flags requires careful thought to avoid bugs. The option parsing could also become complex as more flags are added, which is why using `getopts` would be beneficial for a more robust solution.

For a bonus enhancement, I've already included support for the `--help` flag in the script. To further improve option parsing using `getopts`, we could refactor the argument parsing section.

## Installation

1. Download the script
2. Make it executable: `chmod +x mygrep.sh`
3. Run it as shown in the examples
