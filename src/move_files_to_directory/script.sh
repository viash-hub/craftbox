#!/bin/bash

set -eo pipefail

## VIASH START
par_input="input.txt;input_2.txt"
par_output="output"
## VIASH END


if [[ ! -d "$par_output" ]]; then
  mkdir -p "$par_output"
fi

# Process multiple input files
IFS=";" read -ra input_files <<< "$par_input"
for file in "${input_files[@]}"; do
  # Check if the file exists before copying
  if [[ -f "$file" ]]; then
    cp "$file" "$par_output/"
    echo "Copied $file to $par_output/"
  else
    echo "Warning: Input file $file does not exist, skipping"
  fi
done
