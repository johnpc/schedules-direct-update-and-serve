FROM ubuntu
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y bash
RUN apt-get install -y xmltv-util
RUN apt-get install -y nginx
# Install cron in addition to your other packages
RUN apt-get update && apt-get install -y cron

# Set up cron to refresh from schedules direct
COPY tvgrab-cron /etc/cron.d/tvgrab-cron
RUN chmod 0644 /etc/cron.d/tvgrab-cron
RUN crontab /etc/cron.d/tvgrab-cron

# Create an entrypoint script to generate the config with the password
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Set the entrypoint
ENTRYPOINT ["/start.sh"]