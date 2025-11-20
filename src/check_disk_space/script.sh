#!/bin/bash

# Check temporary directory space
tmp_avail_kb=$(df -k "$meta_temp_dir" | awk 'NR==2 {print $4}')
tmp_avail_mb=$((tmp_avail_kb / 1024))
echo -e "\nTemporary directory ($meta_temp_dir) available space: ${tmp_avail_mb}MB" >> "$par_output"

if [ "$tmp_avail_mb" -lt "$par_tmp_space_required" ]; then
    echo "WARNING: Available temporary space (${tmp_avail_mb}MB) is less than required (${par_tmp_space_required}MB)" | tee -a "$par_output"
fi

# Check publish directory space if specified
publish_avail_kb=$(df -k "$par_publish_dir" | awk 'NR==2 {print $4}')
publish_avail_mb=$((publish_avail_kb / 1024))
echo -e "\nPublish directory ($par_publish_dir) available space: ${publish_avail_mb}MB" >> "$par_output"

if [ "$publish_avail_mb" -lt "$par_publish_space_required" ]; then
    echo "WARNING: Available publish space (${publish_avail_mb}MB) is less than required (${par_publish_space_required}MB)" | tee -a "$par_output"
fi