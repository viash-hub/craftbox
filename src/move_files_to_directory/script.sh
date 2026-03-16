#!/bin/bash

set -eo pipefail

## VIASH START
par_input="input.txt;input_dir.zarr"
par_output="output"
par_keep_symbolic_links="false"
par_file_id=""
par_output_summary=""
## VIASH END

if [[ ! -d "$par_output" ]]; then
  mkdir -p "$par_output"
fi

# Set copy flags based on options
if [[ "$par_keep_symbolic_links" == "true" ]]; then
  # -a implies -dR --preserve=all
  # with -d: same as --no-dereference (and --preserve=links)
  # and --no-dereference: never follow symbolic links in SOURCE
  # and -R, -r, --recursive: copy directories recursively
  # --keep-directory-symlink: if the destination already exists and is a
  #   symbolic link to a directory, follow the symlink and copy into the directory
  #   it points to, instead of removing the symlink and creating a real directory in its place.
  cp_flags="-a --keep-directory-symlink"
else
  # -L: always follow symbolic links in SOURCE
  cp_flags="-Lr --preserve=all --no-preserve=link --keep-directory-symlink"
fi

# Process multiple input paths (files or directories)
IFS=";" read -ra input_paths <<< "$par_input"

# Handle output summary CSV generation
if [[ -n "$par_output_summary" ]]; then
  # Require file_id when output_summary is requested
  if [[ -z "$par_file_id" ]]; then
    echo "Error: --output_summary requires --file_id to be provided for file mapping"
    exit 1
  fi
  
  # Parse and validate file IDs
  IFS=";" read -ra file_ids <<< "$par_file_id"
  
  # Validate that number of file IDs matches number of inputs
  if [[ ${#file_ids[@]} -ne ${#input_paths[@]} ]]; then
    echo "Error: Number of file IDs (${#file_ids[@]}) must match number of input paths (${#input_paths[@]})"
    exit 1
  fi
  
  # Initialize CSV file with header
  echo "id,output_file_path" > "$par_output_summary"
fi

for i in "${!input_paths[@]}"; do
  path="${input_paths[$i]}"
  if [[ -e "$path" ]] || [[ -L "$path" ]]; then
    # Get the basename of the input path for the destination
    basename_path=$(basename "$path")
    destination="$par_output/$basename_path"
    
    cp $cp_flags "$path" "$par_output/"
    echo "Copied $path to $destination"
    
    # Add to CSV if output summary is enabled
    if [[ -n "$par_output_summary" ]]; then
      file_id="${file_ids[$i]}"
      echo "$file_id,$destination" >> "$par_output_summary"
    fi
  else
    echo "Warning: Input path $path does not exist, skipping"
  fi
done

# Print CSV location if generated
if [[ -n "$par_output_summary" ]]; then
  echo "File mapping CSV generated at: $par_output_summary"
fi
