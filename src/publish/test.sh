#!/usr/bin/env bash
set -ex

touch test_file.txt
touch another_file.txt

./publish \
  --input test_file.txt \
  --input another_file.txt \
  --output test_output

[[ ! -d test_output ]] && echo "It seems no output directory is generated" && exit 1
[[ ! -f test_output/test_file.txt ]] && [[ ! -f test_output/another_file.txt ]] && echo "Output files were not copied to the output directory" && exit 1
[[ ! -f test_output/another_file.txt ]] && echo "It seems no output file is generated" && exit 1

exit 0