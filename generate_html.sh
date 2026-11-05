#!/bin/bash

# Default to the current directory (.) if no argument is provided
TARGET_DIR="${1:-.}"
OUTPUT_FILE="directory_list.html"

# Verify the path is a valid directory
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: '$TARGET_DIR' is not a valid directory."
    exit 1
fi

# Convert relative path to an absolute path for cleaner display
ABS_TARGET_DIR=$(cd "$TARGET_DIR" && pwd)

echo "Generating HTML list for: $ABS_TARGET_DIR..."

# Build the HTML structure
echo "<ul>" > "$OUTPUT_FILE"
find "$ABS_TARGET_DIR" -type f | while read -r file; do
    echo "  <li>$file</li>"
done >> "$OUTPUT_FILE"
echo "</ul>" >> "$OUTPUT_FILE"

echo "Done! Saved to $OUTPUT_FILE"
