#!/bin/sh

persist="$PERSIST_DIRS\n$PERSIST_FILES"

unique_dirs=$(echo -e "$persist" | xargs -n 1 dirname | while read -r dir; do
        while [ "$dir" != "/" ]; do
            echo "$dir"
            dir=$(dirname "$dir")
        done
done | sort -u)

unique_dirs_array=()
while IFS= read -r line; do
    unique_dirs_array+=("$line")
done <<< "$unique_dirs"
unique_dirs_array+=("")

persist_array=()
while IFS= read -r line; do
    persist_array+=("$line")
done <<< "$(echo -e "$persist")"

for unique_dir in "${unique_dirs_array[@]}"; do
    for entry in "/persist$unique_dir"/*; do
        found=0
        for dir in "${persist_array[@]}"; do
            if [ "$entry" = "/persist$dir" ]; then
                found=1
                break
            fi
        done
        for dir in "${unique_dirs_array[@]}"; do
            if [ "$entry" = "/persist$dir" ]; then
                found=1
                break
            fi
        done
        if [ "$found" -eq 0 ]; then
            echo "Deleting: $entry"
            rm -rf "$entry"
        fi
    done
done
