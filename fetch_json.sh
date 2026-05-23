#!/bin/bash
# Scheduled update of Schedules Direct data

set -o pipefail

output=/var/www/html/tvxml.xml
tmp_output="${output}.new"
status_file=/var/www/html/status.json
error_log=/var/www/html/last_error.log

echo "$(date '+%Y-%m-%d %H:%M:%S') - [SCHEDULED SYNC] Starting Schedules Direct data fetch..."

rm -f "${tmp_output}"

# Capture both stdout and stderr from tv_grab_zz_sdjson
stderr_tmp=$(mktemp)
/usr/bin/tv_grab_zz_sdjson --config-file /var/www/html/tv_grab_zz_sdjson.conf --output "${tmp_output}" --days "${SD_FETCH_DAYS}" 2>"${stderr_tmp}"
rc=$?

if [ ${rc} -eq 0 ]; then
  if [ -s "${tmp_output}" ] && head -c 200 "${tmp_output}" | grep -Eq '<\?xml|<tv'; then
    mv "${tmp_output}" "${output}"
    file_size=$(stat -c %s "${output}")
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [SCHEDULED SYNC] Replaced ${output} with ${file_size} bytes"
    # Write success status
    cat > "${status_file}" << EOF
{"status":"ok","last_success":"$(date -Iseconds)","file_size":${file_size},"error":null}
EOF
    rm -f "${error_log}" "${stderr_tmp}"
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [SCHEDULED SYNC] Refusing to replace ${output}; temp output was empty or not XML" >&2
    cat > "${status_file}" << EOF
{"status":"error","last_failure":"$(date -Iseconds)","exit_code":2,"error":"Output was empty or not valid XML"}
EOF
    rm -f "${tmp_output}" "${stderr_tmp}"
    exit 2
  fi
else
  error_output=$(cat "${stderr_tmp}")
  echo "$(date '+%Y-%m-%d %H:%M:%S') - [SCHEDULED SYNC] Fetch failed with exit ${rc}; keeping existing ${output}" >&2
  echo "$(date '+%Y-%m-%d %H:%M:%S') - [SCHEDULED SYNC] stderr: ${error_output}" >&2
  # Persist error details
  echo "${error_output}" > "${error_log}"
  cat > "${status_file}" << EOF
{"status":"error","last_failure":"$(date -Iseconds)","exit_code":${rc},"error":$(echo "${error_output}" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read().strip()))' 2>/dev/null || echo "\"${error_output}\"")}
EOF
  rm -f "${tmp_output}" "${stderr_tmp}"
  exit "${rc}"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - [SCHEDULED SYNC] Completed Schedules Direct data fetch"
