#!/bin/bash

# Function to display usage information
show_usage() {
    echo "Usage: $0 [OPTIONS] PATTERN FILE"
    echo "Search for PATTERN in FILE"
    echo
    echo "Options:"
    echo "  -n         Show line numbers for each match"
    echo "  -v         Invert the match (print lines that do not match)"
    echo "  --help     Display this help and exit"
    exit 1
}

# Check if help flag is provided
if [[ "$1" == "--help" ]]; then
    show_usage
fi

# Initialize variables
show_line_numbers=false
invert_match=false
pattern=""
file=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n)
            show_line_numbers=true
            shift
            ;;
        -v)
            invert_match=true
            shift
            ;;
        -nv|-vn)
            show_line_numbers=true
            invert_match=true
            shift
            ;;
        -*)
            echo "Error: Unknown option: $1"
            show_usage
            ;;
        *)
            if [[ -z "$pattern" ]]; then
                pattern="$1"
            elif [[ -z "$file" ]]; then
                file="$1"
            else
                echo "Error: Too many arguments"
                show_usage
            fi
            shift
            ;;
    esac
done

# Check if required arguments are provided
if [[ -z "$pattern" ]]; then
    echo "Error: Missing search pattern"
    show_usage
fi

if [[ -z "$file" ]]; then
    echo "Error: Missing search string"
    show_usage
fi

# Check if file exists
if [[ ! -f "$file" ]]; then
    echo "Error: File '$file' does not exist"
    exit 1
fi

# Process the file
line_number=0
while IFS= read -r line; do
    line_number=$((line_number + 1))
    # Case-insensitive search by converting both line and pattern to lowercase
    lowercase_line=$(echo "$line" | tr '[:upper:]' '[:lower:]')
    lowercase_pattern=$(echo "$pattern" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$lowercase_line" == *"$lowercase_pattern"* ]]; then
        match=true
    else
        match=false
    fi
    
    # Handle inverted match
    if [[ "$invert_match" == true ]]; then
        # Properly invert the boolean value
        if [[ "$match" == true ]]; then
            match=false
        else
            match=true
        fi
    fi
    
    # Display the matching line
    if [[ "$match" == true ]]; then
        if [[ "$show_line_numbers" == true ]]; then
            echo "$line_number:$line"
        else
            echo "$line"
        fi
    fi
done < "$file"