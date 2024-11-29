#!/bin/bash

set -x
login='nitrobass24'
pass=''
host='white.seedhost.eu'
port='22'
remote_dir='~/downloads/completed'
local_dir='/ssdpool/sftpsync'
final_dir='/mnt/Home_Data/Downloads/Import'
temp_extract_dir='/pool2/unrar_tmp'
nfile='15'
nsegment='50'
minchunk='250M'

base_name="$(basename "$0")"
lock_file="/tmp/${base_name}.lock"
echo "${0} Starting at $(date)"
if [ -e "${lock_file}" ]; then
    echo "${base_name} is running already."
    exit 1
else
    touch "${lock_file}"
    trap 'rm -f "${lock_file}"' SIGINT SIGTERM EXIT
    ionice -c 2 -n 0 nice -n 10 /usr/bin/lftp -p "${port}" -u "${login},${pass}" sftp://"${host}" << EOF
        mv "${remote_dir}" "${remote_dir}_lftp"
        mkdir -p "${remote_dir}"
        set net:socket-buffer 33554432  # 32MB socket buffer
        set ftp:list-options -a
        set sftp:auto-confirm yes
        set pget:min-chunk-size ${minchunk}
        set pget:default-n ${nsegment}
        set mirror:use-pget-n ${nsegment}
        set mirror:parallel-transfer-count ${nfile}
        set mirror:parallel-directories yes
        set xfer:use-temp-file yes
        set xfer:temp-file-name *.lftp
        mirror -c -v --loop --Remove-source-dirs "${remote_dir}_lftp" "${local_dir}"
        quit
EOF
fi

# Move single non-RAR files directly in local_dir to final_dir
find "$local_dir" -mindepth 1 -maxdepth 1 -type f ! -name "*.rar" -print0 | while IFS= read -r -d '' file; do
    rsync -a --no-perms --no-owner --no-group --inplace "$file" "$final_dir/"
    rm -f "$file"
done

# Check if there are directories or files to process before proceeding
if [ -n "$(find "$local_dir" -mindepth 1 -maxdepth 1)" ]; then
    # Find all directories in the local directory
    find "$local_dir" -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 -P 2 -I {} bash -c '
        dir="{}"
        base_name=$(basename "$dir")
        temp_subdir="'$temp_extract_dir'/$base_name"
        dest_dir="'$final_dir'/$base_name"

        # Create the temporary extraction directory and the destination directory
        mkdir -p "$temp_subdir"
        mkdir -p "$dest_dir"

        # Check for RAR files in the directory
        rar_files_found=false
        if find "$dir" -type f -name "*.rar" | grep -q "."; then
            rar_files_found=true
        fi

        # Extract RAR files if found
        if [ "$rar_files_found" = true ]; then
            find "$dir" -type f -name "*.rar" | while read -r rar_file; do
                ionice -c 2 -n 0 unrar x -mt "$rar_file" "$temp_subdir"
            done
            # Move extracted files to the final destination
            rsync -a --no-perms --no-owner --no-group --inplace "$temp_subdir/" "$dest_dir/"
        else
            # Move the entire folder content directly to the destination if no RARs are present
            rsync -a --no-perms --no-owner --no-group --inplace "$dir/" "$dest_dir/"
        fi

        # Clean up the temporary files and the original directory
        rm -rf "$temp_subdir"
        rm -rf "$dir"
    '
fi

echo "${0} Finished at $(date)"
exit
