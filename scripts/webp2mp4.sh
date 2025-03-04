#!/bin/bash

# Check for -f flag (force overwrite)
force=false
while getopts ":f" opt; do
    case $opt in
        f)
            force=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

# Loop through all .webp files in the current directory
for file in *.webp; do
    # Check if any .webp files exist
    if [ -e "$file" ]; then
        # Get the filename without the extension
        filename="${file%.webp}"
        # Check if output file already exists
        if [ -e "$filename.mp4" ] && [ "$force" = false ]; then
            echo "Skipping $file: $filename.mp4 already exists (use -f to overwrite)"
            continue
        fi
        # Convert .webp to .mp4 using ImageMagick
        convert "$file" -loop 0 -delay 40 "$filename.mp4"
        echo "Converted $file to $filename.mp4"
    else
        echo "No .webp files found in the current directory."
        exit 1
    fi
done

echo "Conversion complete!"