#!/bin/bash

## VIASH START
par_input='_viash.yaml'
par_output='.'
## VIASH END

extra_params=( )

if [ "$par_dryrun" == "true" ]; then
  extra_params+=( "--dry-run" )
fi

if [ ! -z ${par_exclude+x} ]; then
  IFS=";"
  for var in $par_exclude; do
    unset IFS
    extra_params+=( "--exclude" "$var" )
  done
fi

yq e \
  '.info.test_resources[] | "{type: " + (.type // "s3") + ", path: " + .path + ", dest: " + .dest + "}"' \
  "${par_input}" | \
  while read -r line; do
    path=$(echo "$line" | yq e '.path')
    dest=$(echo "$line" | yq e '.dest')

    echo "Syncing '$path' to '$dest'..."

    rclone sync "$path" "$par_output/$dest"
  done
