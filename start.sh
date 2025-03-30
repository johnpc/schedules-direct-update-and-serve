#!/bin/bash

# Start cron
service cron start

cat > /var/www/html/tv_grab_zz_sdjson.conf << EOF
cache=/var/www/html/tv_grab_zz_sdjson.cache
channel-id-format=default
previously-shown-format=date
username=${SD_USERNAME}
password=${SD_PASSWORD}
mode=lineup
lineup=USA-0000001-CUSTOM
lineup=USA-DITV505-X
lineup=USA-MI21464-X
lineup=USA-YOUTUBE-X
EOF

rm -f /var/www/html/tv_grab_zz_sdjson.cache || echo "No cache file to clean"

# Initial run of the grab command
tv_grab_zz_sdjson --config-file /var/www/html/tv_grab_zz_sdjson.conf --output /var/www/html/tvxml.xml --days 2

# Start nginx in foreground
nginx -g 'daemon off;'
