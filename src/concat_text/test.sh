#!/usr/bin/env bash

set -euo pipefail

echo ">> Running concat_text.sh script"

is_gzipped() {
    # Ensure the file exists and is not empty
    if [ ! -s "$1" ]; then
        return 1
    fi
    # Get the MIME type of the file
    local mime_type
    mime_type=$(file -b --mime-type "$1")
    
    # Check if the MIME type corresponds to gzip.
    if [[ "$mime_type" == "application/gzip" || "$mime_type" == "application/x-gzip" ]]; then
        return 0
    else
        return 1
    fi
}

compare_files() {
  local file1="$1"
  local file2="$2"
  if [[ ! -f "$file1" || ! -f "$file2" ]]; then
    echo "One of the files does not exist: $file1 or $file2"
    return 1
  fi
  # decompress file 1 if need be
  if is_gzipped "$file1"; then
    file1=$(mktemp)
    zcat "$1" > "$file1"
  fi
  # decompress file 2 if need be
  if is_gzipped "$file2"; then
    file2=$(mktemp)
    zcat "$2" > "$file2"
  fi

  if cmp -s "$file1" "$file2"; then
    echo "Files are identical."
    return 0
  else
    echo "Files differ."
    echo "Found:"
    if is_gzipped "$file1"; then
      zcat "$file1" | od -c
    else
      cat "$file1" | od -c
    fi
    echo "Expected:"
    if is_gzipped "$file2"; then
      zcat "$file2" | od -c
    else
      cat "$file2" | od -c
    fi
    return 1
  fi
}

## TEST RESOURCES
echo ">> Creating test input files file[1-3].txt"
INPUT_FILE_1="file1.txt"
INPUT_FILE_2="file2.txt"
INPUT_FILE_3="file3.txt"
echo "one" > "$INPUT_FILE_1"
echo "two" > "$INPUT_FILE_2"
echo "three" > "$INPUT_FILE_3"
echo ">> Created input files"

echo ">> Creating zipped versions at file[1-3].txt.gz"
gzip -k $INPUT_FILE_1
gzip -k $INPUT_FILE_2
gzip -k $INPUT_FILE_3

echo ">> Creating expected output file expected_output.txt and zipped version"
cat > "expected_output.txt" <<EOF
one
two
three
EOF

gzip -k "expected_output.txt"

## RUN TESTS
echo ">> Run component on 3 plain input files, plain output"
$meta_executable \
  --input "$INPUT_FILE_1;$INPUT_FILE_2;$INPUT_FILE_3" \
  --output "output1.txt"
compare_files "output1.txt" "expected_output.txt"

echo ">> Run component on mixed input files, plain output"
$meta_executable \
  --input "$INPUT_FILE_1.gz;$INPUT_FILE_2;$INPUT_FILE_3.gz" \
  --output "output2.txt"
compare_files "output2.txt" "expected_output.txt"

echo ">> Run component on 3 plain input files, zipped output"
$meta_executable \
  --input "$INPUT_FILE_1;$INPUT_FILE_2;$INPUT_FILE_3" \
  --output "output3.txt.gz" \
  --gzip_output
compare_files "output3.txt.gz" "expected_output.txt.gz"

echo ">> Run component on mixed input files, zipped output"
$meta_executable \
  --input "$INPUT_FILE_1.gz;$INPUT_FILE_2;$INPUT_FILE_3.gz" \
  --output "output4.txt.gz" \
  --gzip_output
compare_files "output4.txt.gz" "expected_output.txt.gz"

echo ">> Tests done"
