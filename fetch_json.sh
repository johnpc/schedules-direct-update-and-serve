#!/bin/bash
# Scheduled update of Schedules Direct data

set -o pipefail

output=/var/www/html/tvxml.xml
tmp_output="${output}.new"

echo "$(date '+%Y-%m-%d %H:%M:%S') - [SCHEDULED SYNC] Starting Schedules Direct data fetch..."

rm -f "${tmp_output}"

if /usr/bin/tv_grab_zz_sdjson --config-file /var/www/html/tv_grab_zz_sdjson.conf --output "${tmp_output}" --days "${SD_FETCH_DAYS}"; then
  if [ -s "${tmp_output}" ] && head -c 200 "${tmp_output}" | grep -Eq '<\?xml|<tv'; then
    mv "${tmp_output}" "${output}"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [SCHEDULED SYNC] Replaced ${output} with $(stat -c %s "${output}") bytes"
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [SCHEDULED SYNC] Refusing to replace ${output}; temp output was empty or not XML" >&2
    rm -f "${tmp_output}"
    exit 2
  fi
else
  rc=$?
  echo "$(date '+%Y-%m-%d %H:%M:%S') - [SCHEDULED SYNC] Fetch failed with exit ${rc}; keeping existing ${output}" >&2
  rm -f "${tmp_output}"
  exit "${rc}"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - [SCHEDULED SYNC] Completed Schedules Direct data fetch"
