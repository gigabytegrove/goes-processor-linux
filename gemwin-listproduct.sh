#!/bin/bash

# Directory to scan (defaults to current dir)
DIR="/opt/goes/EMWIN"

# Extract unique EMWIN codes from filenames
find "$DIR" -type f | while read -r file; do
    filename=$(basename "$file")
    # Extract the part after the last dash and before the dot (e.g., RADNTHES from ...-RADNTHES.GIF)
    if [[ "$filename" =~ -([A-Z0-9]+)\.[A-Za-z0-9]+$ ]]; then
        echo "${BASH_REMATCH[1]}"
    fi
done | sort -u
