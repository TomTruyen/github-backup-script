# Use an official Ubuntu as a parent image
FROM ubuntu:latest

# Set the HOME environment variable
ENV HOME=/root

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

# Copy the .env file to the Docker image
COPY .env /tmp/.env

# Append the .env values to /etc/environment
RUN cat /tmp/.env >> /etc/environment && rm /tmp/.env

# Add the cron job
RUN echo "12 0 * * * /usr/local/bin/github_backup_script.sh >> /var/log/github_backup.log 2>&1" >> /tmp/crontab && \
    crontab /tmp/crontab && rm /tmp/crontab

# Create log files for script logs
RUN touch /var/log/github_backup.log

# Copy the global git config from the current machine to the Docker container
COPY .gitconfig $HOME/.gitconfig

# Copy the SSH keys used for Git authentication
COPY id_ed25519 $HOME/.ssh/id_ed25519
COPY id_ed25519.pub $HOME/.ssh/id_ed25519.pub

# Run the cron service and tail logs to keep the container running
CMD cron && tail -f /var/log/github_backup.log
