#!/usr/bin/env bash
set -ex

# create temporary directory and clean up on exit
TMPDIR=$(mktemp -d "$meta_temp_dir/$meta_name-XXXXXX")
function clean_up {
 [[ -d "$TMPDIR" ]] && rm -rf "$TMPDIR"
}
trap clean_up EXIT

touch "$TMPDIR/test_file.txt"
touch "$TMPDIR/another_file.txt"

./move_files_to_directory \
  --input "$TMPDIR/test_file.txt" \
  --input "$TMPDIR/another_file.txt" \
  --output test_output

[[ ! -d "test_output" ]] && echo "It seems no output directory is generated" && exit 1
[[ ! -f "test_output/test_file.txt" ]] && [[ ! -f test_output/another_file.txt ]] && echo "Output files were not copied to the output directory" && exit 1

echo ">> Test succeeded!"