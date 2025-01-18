# Use an official Alpine as a parent image
FROM alpine:latest

# Install necessary packages
RUN apk --no-cache add \
    curl \
    jq \
    bash \
    cron

# Add your script to the Docker image
ADD github_backup_script.sh /usr/local/bin/github_backup_script.sh

# Make the script executable
RUN chmod +x /usr/local/bin/github_backup_script.sh

# Add the cron job
RUN echo "0 0 * * * /usr/local/bin/github_backup_script.sh" > /etc/crontabs/root

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Run the command on container startup
CMD crond && tail -f /var/log/cron.log