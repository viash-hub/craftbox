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
if [[ "$par_keep_symbolic_links" == "true" ]]; then
  cp_flags="-dr"
else
  cp_flags="-r"
fi

# Process multiple input paths (files or directories)
IFS=";" read -ra input_paths <<< "$par_input"
for path in "${input_paths[@]}"; do
  if [[ -e "$path" ]] || [[ -L "$path" ]]; then
    cp $cp_flags "$path" "$par_output/"
    echo "Copied $path to $par_output/"
  else
    echo "Warning: Input path $path does not exist, skipping"
  fi
done
