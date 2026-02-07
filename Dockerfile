# ---- Base Image ----
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root

# ---- Fix Slow Mirrors / IPv6 Issues (Pi Friendly) ----
RUN sed -i 's|http://ports.ubuntu.com/ubuntu-ports|mirror://mirrors.ubuntu.com/mirrors.txt|g' /etc/apt/sources.list

# ---- Install Dependencies ----
RUN apt-get -o Acquire::ForceIPv4=true update && \
    apt-get install -y --no-install-recommends \
        curl \
        jq \
        cron \
        git \
        ca-certificates \
        openssh-client \
    && rm -rf /var/lib/apt/lists/*

# ---- Script ----
COPY github_backup_script.sh /usr/local/bin/github_backup_script.sh
RUN chmod +x /usr/local/bin/github_backup_script.sh

# ---- Environment ----
COPY .env /tmp/.env
RUN cat /tmp/.env >> /etc/environment && rm /tmp/.env

# ---- Cron Job ----
RUN echo "12 0 * * * /usr/local/bin/github_backup_script.sh >> /var/log/github_backup.log 2>&1" > /etc/cron.d/github-backup && \
    chmod 0644 /etc/cron.d/github-backup && \
    crontab /etc/cron.d/github-backup

# ---- Logs ----
RUN touch /var/log/github_backup.log

# ---- Git Config ----
COPY .gitconfig /root/.gitconfig

# ---- SSH (Optional – safer via volume, see compose below) ----
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh
COPY id_ed25519 /root/.ssh/id_ed25519
COPY id_ed25519.pub /root/.ssh/id_ed25519.pub
RUN chmod 600 /root/.ssh/id_ed25519

# ---- Start Cron ----
CMD ["cron", "-f"]
