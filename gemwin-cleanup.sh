#!/bin/bash

# Default values
FOLDER=""
DAYS=""

# Parse arguments
for arg in "$@"
do
    case $arg in
        --folder=*)
        FOLDER="${arg#*=}"
        shift
        ;;
        --days=*)
        DAYS="${arg#*=}"
        shift
        ;;
        *)
        echo "Unknown option: $arg"
        exit 1
        ;;
    esac
done

# Check required arguments
if [[ -z "$FOLDER" || -z "$DAYS" ]]; then
    echo "Usage: $0 --folder=FOLDER_PATH --days=N"
    exit 1
fi

# Check folder exists
if [[ ! -d "$FOLDER" ]]; then
    echo "âŒ Folder '$FOLDER' does not exist."
    exit 1
fi

# Run cleanup
echo "ðŸ§¹ Cleaning up files in '$FOLDER' and subfolders older than $DAYS day(s)..."
find "$FOLDER" -type f -mtime +"$DAYS" -print -delete

# Optional: Clean up empty directories
echo "ðŸ—‘ï¸ Cleaning up empty subdirectories..."
find "$FOLDER" -type d -empty -print -delete

echo "âœ… Cleanup complete."
