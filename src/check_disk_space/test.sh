#!/bin/bash

set -eo pipefail

TMPDIR=$(mktemp -d "$meta_temp_dir/$meta_name-XXXXXX")
function clean_up {
 [[ -d "$TMPDIR" ]] && rm -rf "$TMPDIR"
}
trap clean_up EXIT

# Create test directories
mkdir -p "$TMPDIR/publish"

echo "Test 1: Both directories have enough space"
# Define normal space df function
df() {
  echo "Filesystem     1K-blocks    Used Available Use% Mounted on"
  echo "ext4             20485760 5000000  15485760  25% $2"
}
# Export the function
export -f df
# Run the component
"$meta_executable" \
  --publish_dir "$TMPDIR/publish" \
  --tmp_space_required "500" \
  --publish_space_required "300" \
  --output "$TMPDIR/output1.txt"

# Verify Test 1 - should have no warnings
if grep -q "WARNING:" "$TMPDIR/output1.txt"; then
    echo "FAIL: Unexpected warning in normal space test"
else
    echo "PASS: No warnings with sufficient space"
fi

echo "Test 2: Temporary directory doesn't have enough space"
# Define low temp space df function
df() {
  if [[ "$2" == "$meta_temp_dir" ]]; then
    echo "Filesystem     1K-blocks    Used Available Use% Mounted on"
    echo "tmpfs            10485760 5000000   921600  50% $2"
  else
    echo "Filesystem     1K-blocks    Used Available Use% Mounted on"
    echo "ext4             20485760 5000000  15485760  25% $2"
  fi
}
# Export the function
export -f df
# Run the component
"$meta_executable" \
  --publish_dir "$TMPDIR/publish" \
  --tmp_space_required "1000" \
  --publish_space_required "300" \
  --output "$TMPDIR/output2.txt"

# Verify Test 2
if grep -q "WARNING: Available temporary space" "$TMPDIR/output2.txt"; then
    echo "PASS: Low temp space warning detected"
else
    echo "FAIL: No warning detected for low temp space"
fi

echo "Test 3: Publish directory doesn't have enough space"
# Define low publish space df function
df() {
  if [[ "$2" =~ /publish ]]; then
    echo "Filesystem     1K-blocks    Used Available Use% Mounted on"
    echo "ext4             20485760 16384000   409600  80% $2"
  else
    echo "Filesystem     1K-blocks    Used Available Use% Mounted on"
    echo "ext4             20485760 5000000  15485760  25% $2"
  fi
}
# Export the function
export -f df
# Run the component
"$meta_executable" \
  --publish_dir "$TMPDIR/publish" \
  --tmp_space_required "500" \
  --publish_space_required "500" \
  --output "$TMPDIR/output3.txt"

# Verify Test 3
if grep -q "WARNING: Available publish space" "$TMPDIR/output3.txt"; then
    echo "PASS: Low publish space warning detected"
else
    echo "FAIL: No warning detected for low publish space"
fi

echo "All tests completed"

exit 0