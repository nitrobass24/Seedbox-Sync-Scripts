#!/bin/bash

torrent_syncdir="/volume1/downloads/sync"
base_dir=$(basename $sonarr_episodefile_sourcefolder)

if ! [[ "${sonarr_episodefile_sourcepath}" =~ ${torrent_syncdir} ]]; then
  echo "[Torrent Cleanup] Path ${sonarr_episodefile_sourcepath} does not contain ${torrent_syncdir}, exiting."
  exit
fi
if [ "${base_dir}" == "${torrent_syncdir}" ];then
    echo "Single file torrent, deleting ${sonarr_episodefile_sourcepath}"
    rm ${sonarr_episodefile_sourcepath}
    exit
else
    echo "Deleting torrent directory ${sonarr_episodefile_sourcefolder}"
    rm -rf ${sonarr_episodefile_sourcefolder}
    exit
fi
