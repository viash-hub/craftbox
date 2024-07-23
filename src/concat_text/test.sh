#!/usr/bin/env bash

set -eo pipefail

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

echo ">> Run component on 3 plain input files, plain output"
$meta_executable \
  --input "$INPUT_FILE_1;$INPUT_FILE_2;$INPUT_FILE_3" \
  --output "output1.txt"

[[ ! -f "output1.txt" ]] \
  && echo "Output file output1.txt not found!" && exit 1
[[ $(cmp "output1.txt" "expected_output.txt") ]] \
  && echo "Output file output1.txt is not as expected!" && exit 1

echo ">> Run component on 3 zipped input files, plain output"
$meta_executable \
  --input "$INPUT_FILE_1.gz;$INPUT_FILE_2.gz;$INPUT_FILE_3.gz" \
  --output "output2.txt"

[[ ! -f "output2.txt" ]] \
  && echo "Output file output2.txt not found!" && exit 1
[[ $(cmp "output2.txt" "expected_output.txt") ]] \
  && echo "Output file output2.txt is not as expected!" && exit 1

echo ">> Run component on 3 plain input files, zipped output"
$meta_executable \
  --input "$INPUT_FILE_1;$INPUT_FILE_2;$INPUT_FILE_3" \
  --output "output3.txt.gz" \
  --zip_output

[[ ! -f "output3.txt.gz" ]] \
  && echo "Output file output3.txt.gz not found!" && exit 1
[[ $(cmp "output3.txt.gz" "expected_output.txt.gz") ]] \
  && echo "Output file output3.txt.gz is not as expected!" && exit 1

echo ">> Run component on 3 zipped input files, zipped output"
$meta_executable \
  --input "$INPUT_FILE_1.gz;$INPUT_FILE_2.gz;$INPUT_FILE_3.gz" \
  --output "output4.txt.gz" \
  --zip_output

[[ ! -f "output4.txt.gz" ]] \
  && echo "Output file output4.txt.gz not found!" && exit 1
[[ $(cmp "output4.txt.gz" "expected_output.txt.gz") ]] \
  && echo "Output file output4.txt.gz is not as expected!" && exit 1

echo ">> Tests done, cleaning up"
