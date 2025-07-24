#!/bin/bash
# Scheduled update of Schedules Direct data

echo "$(date '+%Y-%m-%d %H:%M:%S') - [SCHEDULED SYNC] Starting Schedules Direct data fetch..."

# Run the tv_grab_zz_sdjson command with the config file
/usr/bin/tv_grab_zz_sdjson --config-file /var/www/html/tv_grab_zz_sdjson.conf --output /var/www/html/tvxml.xml --days ${SD_FETCH_DAYS}

echo "$(date '+%Y-%m-%d %H:%M:%S') - [SCHEDULED SYNC] Completed Schedules Direct data fetch"
