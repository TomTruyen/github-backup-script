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

# Export environment variables for cron jobs
RUN printenv | grep -v "no_proxy" > /etc/environment

# Add the cron job and load the environment variables before execution
RUN echo "*/10 * * * * bash -c '. /etc/environment && /usr/local/bin/github_backup_script.sh >> /var/log/github_backup.log 2>&1'" >> /tmp/crontab && \
    crontab /tmp/crontab && rm /tmp/crontab

# Create log files for cron and script logs
RUN touch /var/log/cron.log /var/log/github_backup.log

# Copy the global git config from the current machine to the Docker container
COPY .gitconfig /root/.gitconfig

# Copy the SSH keys used for Git authentication
COPY id_ed25519 /root/.ssh/id_ed25519
COPY id_ed25519.pub /root/.ssh/id_ed25519.pub

# Run the cron service and tail both logs to keep the container running
CMD cron && tail -f /var/log/cron.log /var/log/github_backup.log
