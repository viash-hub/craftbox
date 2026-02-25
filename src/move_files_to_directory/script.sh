#!/bin/bash

set -eo pipefail

## VIASH START
par_input="input.txt;input_dir.zarr"
par_output="output"
par_keep_symbolic_links="false"
## VIASH END

if [[ ! -d "$par_output" ]]; then
  mkdir -p "$par_output"
fi

# Set copy flags based on options
cp_flags=""
if [[ "$par_keep_symbolic_links" == "true" ]]; then
  cp_flags="-P"
fi

# Process multiple input paths (files or directories)
IFS=";" read -ra input_paths <<< "$par_input"
for path in "${input_paths[@]}"; do
  if [[ -L "$path" ]] || [[ -f "$path" ]]; then
    cp $cp_flags "$path" "$par_output/"
    echo "Copied file $path to $par_output/"
  elif [[ -d "$path" ]]; then
    cp -r $cp_flags "$path" "$par_output/"
    echo "Copied directory $path to $par_output/"
  else
    echo "Warning: Input path $path does not exist, skipping"
  fi
done
