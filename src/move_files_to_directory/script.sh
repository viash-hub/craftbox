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
for path in "${input_paths[@]}"; do
  if [[ -e "$path" ]] || [[ -L "$path" ]]; then
    cp $cp_flags "$path" "$par_output/"
    echo "Copied $path to $par_output/"
  else
    echo "Warning: Input path $path does not exist, skipping"
  fi
done
