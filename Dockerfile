# Use an official Ubuntu as a parent image
FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    cron \
    git \
    && rm -rf /var/lib/apt/lists/*

# Add your script to the Docker image
ADD github_backup_script.sh /usr/local/bin/github_backup_script.sh

# Make the script executable
RUN chmod +x /usr/local/bin/github_backup_script.sh

# Add the cron job
RUN echo "0 0 * * * /usr/local/bin/github_backup_script.sh" > /etc/cron.d/github_backup

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/github_backup

# Apply cron job
RUN crontab /etc/cron.d/github_backup

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Copy the global git config from the current machine to the Docker container
COPY ~/.gitconfig /root/.gitconfig

# Copy the SSH keys used for Git authentication
COPY ~/.ssh/id_ed25519 /root/.ssh/id_ed25519
COPY ~/.ssh/id_ed25519.pub /root/.ssh/id_ed25519.pub

# Run the command on container startup
CMD cron && tail -f /var/log/cron.log