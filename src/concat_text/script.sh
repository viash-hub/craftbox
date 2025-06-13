#!/usr/bin/env bash

set -eo pipefail

## VIASH START
par_input="README.md;README.qmd"
par_output="concatenated_output.txt"
par_compress_output="true"
## VIASH END

# --- Function to check for GZIP format using the 'file' command ---
is_gzipped() {
    # Ensure the file exists and is not empty before checking
    if [ ! -s "$1" ]; then
        return 1
    fi
    # Get the MIME type of the file. The '-b' option omits the filename from the output.
    local mime_type
    mime_type=$(file -b --mime-type "$1")
    
    # Check if the MIME type corresponds to gzip.
    # application/gzip is standard, while application/x-gzip is also commonly seen.
    if [[ "$mime_type" == "application/gzip" || "$mime_type" == "application/x-gzip" ]]; then
        return 0 # 0 indicates success (true in bash)
    else
        return 1 # 1 indicates failure (false in bash)
    fi
}

# Read the ;-separated file paths from the input variable into an array
IFS=";" read -ra input_files <<< "$par_input"

# Process the files if the array contains any paths
if [ ${#input_files[@]} -gt 0 ] && [ -n "${input_files[0]}" ]; then

    # Ensure the output file is empty before we start
    > "$par_output"

    echo "Processing files for -> $par_output"

    # Create a subshell for the loop to group all cat/zcat output.
    (
        for file in "${input_files[@]}"; do
            if [ -z "$file" ]; then continue; fi # Skip empty entries in the array

            if is_gzipped "$file"; then
                zcat "$file"
            else
                cat "$file"
            fi
        done
    ) | if [ "$par_compress_output" = "true" ]; then
        # If compression is enabled, pipe the entire stream to gzip
        gzip -c >> "$par_output"
    else
        # Otherwise, just redirect the stream to the plain text file
        cat >> "$par_output"
    fi

    echo "Finished creating $par_output."
else
    echo "No input files provided in \$par_input. Exiting."
fi

echo "Script finished successfully."
