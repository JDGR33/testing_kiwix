#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
data_dir="${1:-${script_dir}/data}"
library_file="${data_dir}/library.xml"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required to rebuild the Kiwix library." >&2
  exit 1
fi

mapfile -d '' zim_files < <(find "$data_dir" -maxdepth 1 -type f -name '*.zim' -printf '%f\0' | sort -z)

if [ "${#zim_files[@]}" -eq 0 ]; then
  echo "No .zim files found in ${data_dir}." >&2
  exit 1
fi

rm -f "$library_file"

args=(/data/library.xml add)
for zim_file in "${zim_files[@]}"; do
  args+=("/data/${zim_file}")
done

echo "Updated ${library_file} with ${#zim_files[@]} ZIM file(s)."