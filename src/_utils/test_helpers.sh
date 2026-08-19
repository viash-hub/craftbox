#!/bin/bash

# Test Helper Functions for Biobox Components
# 
# This file provides standardized helper functions for component testing.
# Source this file in your test scripts with:
# source "$meta_resources_dir/test_helpers.sh"
#
# Usage examples:
#   log "Starting test execution"
#   check_file_exists "$output" "result file"
#   check_file_not_exists "$bam_file" "BAM file (disabled by default)"
#   create_test_fasta "$temp_dir/input.fasta" 3 50
#

#############################################
# Logging Functions
#############################################


#############################################
# Logging Functions
#############################################

# Log messages with timestamps and consistent formatting
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [TEST] $*"
}

# Log informational messages (alias for log)
log_info() {
  log "$*"
}

# Log warning messages
log_warn() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] $*"
}

# Log error messages
log_error() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $*" >&2
}


#############################################
# File and Directory Validation Functions
#############################################


# Check if a file exists with descriptive logging
# Usage: check_file_exists "/path/to/file" "optional description"
check_file_exists() {
  local file_path="$1"
  local description="${2:-File}"
  
  if [[ -f "$file_path" ]]; then
    log "✓ Found $description: $file_path"
    return 0
  else
    log_error "✗ $description does not exist: $file_path"
    exit 1
  fi
}

# Print test summary
print_test_summary() {
  local test_name="${1:-Test}"
  log "🎉 $test_name completed successfully!"
}
