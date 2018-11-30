#!/bin/bash

#variables 
login='username' #seedbox username
pass='password' #seedbox password
host='hostname' #e.g. test.seedhost.eu
port='22'
remote_dir='~/downloads/completed'
local_dir='/volume1/downloads/sync'
nfile='2' # Number of files to download simultaneously
nsegment='4' # Number of segments/parts to split the downloads into
minchunk='1M' # Minimum size each chunk (part) should be

#set binary paths
lftp=`which lftp`
unrar=`which unrar`

# LFTP Sync portion
base_name="$(basename "$0")"
lock_file="/tmp/${base_name}.lock"
echo "${0} Starting at $(date)"
trap "rm -f ${lock_file}" SIGINT SIGTERM
if [ -e "${lock_file}" ]
then
    echo "${base_name} is running already."
	exit
else
	touch "${lock_file}"
	$lftp -p "${port}" -u "${login},${pass}" sftp://"${host}" << EOF
	mv "${remote_dir}" "${remote_dir}_lftp"
	mkdir -p "${remote_dir}"
	set ftp:list-options -a
	set sftp:auto-confirm yes
	set pget:min-chunk-size ${minchunk}
	set pget:default-n ${nsegment}
	set cmd:queue-parallel ${nfile}
	set mirror:use-pget-n ${nsegment}
	set mirror:parallel-transfer-count ${nfile}
	set mirror:parallel-directories yes
	set xfer:use-temp-file yes
	set xfer:temp-file-name *.lftp    
	mirror -c -v --loop --Remove-source-dirs "${remote_dir}_lftp" "${local_dir}"
	quit
EOF
fi

#Logic for extracting downloads
list=`find $local_dir -type f -name *.rar`
for line in $list; do
DEST=${line%/*}
$unrar x -o- $line $DEST
done

#clean up and end script
rm -f "${lock_file}"
trap - SIGINT SIGTERM
echo "${0} Finished at $(date)"
exit
