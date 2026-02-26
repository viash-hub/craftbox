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
  --output "$TMPDIR/test_output"

[[ ! -d "$TMPDIR/test_output" ]] && echo "It seems no output directory is generated" && exit 1
[[ ! -f "$TMPDIR/test_output/test_file.txt" ]] && [[ ! -f test_output/another_file.txt ]] && echo "Output files were not copied to the output directory" && exit 1

# Test copying a directory
mkdir -p "$TMPDIR/test_dir"
touch "$TMPDIR/test_dir/file_in_dir.txt"
touch "$TMPDIR/test_dir/another_file_in_dir.txt"

./move_files_to_directory \
  --input "$TMPDIR/test_dir" \
  --output "$TMPDIR/test_output_dir"

[[ ! -d "$TMPDIR/test_output_dir" ]] && echo "It seems no output directory (test_output_dir) is generated" && exit 1
[[ ! -d "$TMPDIR/test_output_dir/test_dir" ]] && echo "Input directory was not copied to the output directory" && exit 1
[[ ! -f "$TMPDIR/test_output_dir/test_dir/file_in_dir.txt" ]] && echo "Files inside the copied directory are missing" && exit 1
[[ ! -f "$TMPDIR/test_output_dir/test_dir/another_file_in_dir.txt" ]] && echo "Files inside the copied directory are missing" && exit 1

ln -s "$TMPDIR/test_file.txt" "$TMPDIR/symlink.txt"

./move_files_to_directory \
  --input "$TMPDIR/symlink.txt" \
  --output "$TMPDIR/test_output_symlink" \
  --keep_symbolic_links
[[ ! -d "$TMPDIR/test_output_symlink" ]] && echo "It seems no output directory (test_output_symlink) is generated" && exit 1
[[ ! -h "$TMPDIR/test_output_symlink/symlink.txt" ]] && echo "Symbolic links were not properly copied." && exit 1

echo ">> Test succeeded!"