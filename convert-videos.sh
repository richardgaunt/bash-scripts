#!/bin/bash

# Directory to search for MP4 files
DIRECTORY="$1" # Change this to your target directory if needed

# Loop through all MP4 files in the directory
for file in "$DIRECTORY"/*.mp4; do
    # Check if the file exists (to handle cases where no MP4 files are found)
    if [ ! -f "$file" ]; then
        echo "No MP4 files found in the directory!"
        exit 1
    fi

    # Extract the file name without extension
    filename=$(basename -- "$file")
    filename_no_ext="${filename%.*}"

    # Define the output file
    output_file="$DIRECTORY/${filename_no_ext}_reencoded.mp4"

    # Re-encode the file
    echo "Re-encoding $file to $output_file ..."
    ffmpeg -i "$file" -c:v libx264 -crf 30 -preset medium -c:a aac "$output_file"

    # Check if encoding succeeded
    if [ $? -eq 0 ]; then
        echo "Successfully re-encoded $file"
    else
        echo "Failed to re-encode $file"
    fi
done

echo "All files processed."
