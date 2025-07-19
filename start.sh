#!/bin/bash

# Store environment variables for cron runs
printenv > /etc/environment
crontab /etc/cron.d/tvgrab-cron

# Start cron
service cron start

# Create the base configuration
cat > /var/www/html/tv_grab_zz_sdjson.conf << EOF
cache=/var/www/html/tv_grab_zz_sdjson.cache
channel-id-format=default
previously-shown-format=date
username=${SD_USERNAME}
password=${SD_PASSWORD}
mode=lineup
EOF

# Add lineups from environment variable
# If SD_LINEUPS is not set, use default lineups
if [ -z "${SD_LINEUPS}" ]; then
  # Default lineups if none specified
  DEFAULT_LINEUPS="USA-0000001-CUSTOM,USA-DITV505-X,USA-MI21464-X,USA-YOUTUBE-X"
  echo "No lineups specified, using defaults: ${DEFAULT_LINEUPS}"
  SD_LINEUPS="${DEFAULT_LINEUPS}"
fi

# Add number of days to fetch guide data for
fetch_days=${SD_FETCH_DAYS}

# Process comma-separated lineup list
IFS=',' read -ra LINEUP_ARRAY <<< "${SD_LINEUPS}"
for lineup in "${LINEUP_ARRAY[@]}"; do
  # Trim whitespace
  lineup=$(echo "${lineup}" | xargs)
  if [ ! -z "${lineup}" ]; then
    echo "Adding lineup: ${lineup}"
    echo "lineup=${lineup}" >> /var/www/html/tv_grab_zz_sdjson.conf
  fi
done

rm -f /var/www/html/tv_grab_zz_sdjson.cache || echo "No cache file to clean"

# Initial run of the grab command
echo "$(date '+%Y-%m-%d %H:%M:%S') - [INITIAL SYNC] Starting Schedules Direct data fetch..."
tv_grab_zz_sdjson --config-file /var/www/html/tv_grab_zz_sdjson.conf --output /var/www/html/tvxml.xml --days $fetch_days
echo "$(date '+%Y-%m-%d %H:%M:%S') - [INITIAL SYNC] Completed Schedules Direct data fetch"

# Set up log rotation for cron.log
cat > /etc/logrotate.d/cron << EOF
/var/log/cron.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root root
}
EOF

# Start nginx in foreground
nginx -g 'daemon off;'
