# craftbox 0.2.0

## NEW FEATURES

* `sync_resources`: Sync a Viash package's test resources to the local filesystem (PR #7).

* `move_files_to_directory`: Publish one or multiple files to an output directory (PR #10).

## MINOR CHANGES

* Add documentation to multiple components (PR #9).

* Bump Viash to 0.9.4 (PR #9, PR #11).

* Update documentation and package metadata (PR #11).

## BUG FIXES

* `untar`: Fix usage of a deprecated environment variable (PR #8).

# craftbox 0.1.0

## NEW FEATURES

* `concat_text`: Concatenate a number of text files

* `csv2fasta`: Convert two columns from a CSV file to FASTA entries (PR #1).

* `untar`: Unpack a .tar file. When the contents of the .tar file is just a single directory,
   put the contents of the directory into the output folder instead of that directory (PR #3).

## MINOR CHANGES

* Bump viash to 0.9.0
