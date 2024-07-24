#!/usr/bin/env bash

set -euo pipefail

TMPDIR=$(mktemp -d "$meta_temp_dir/concat_text-XXXXXX")
function clean_up {
  [[ -d "$TMPDIR" ]] && rm -r "$TMPDIR"
}
trap clean_up EXIT

par_input="$(echo "$par_input" | tr ';' ' ')"

echo -n ">> Check if input is gzipped... "
set +eo pipefail
file $par_input | grep -q 'gzip'
is_zipped="$?"
set -euo pipefail
[[ "$is_zipped" == "0" ]] && echo "yes" || echo "no"

if [[ "$is_zipped" == "0" ]]; then
  echo ">> zcat gzipped files"
  zcat $par_input > $TMPDIR/contents
else
  echo ">> cat plain files"
  cat $par_input > $TMPDIR/contents
fi

if [ "$par_gzip_output" == true ]; then
  echo ">> Zip output file"
  gzip $TMPDIR/contents
  mv $TMPDIR/contents.gz $par_output
else
  mv $TMPDIR/contents $par_output
fi
