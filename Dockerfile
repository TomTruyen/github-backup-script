FROM ubuntu:latest

ENV HOME=/root

RUN apt-get update && apt-get install -y \
    curl \
    jq \
    cron \
    git \
    && rm -rf /var/lib/apt/lists/*

COPY github_backup_script.sh /usr/local/bin/github_backup_script.sh
RUN chmod +x /usr/local/bin/github_backup_script.sh

COPY .env /tmp/.env
RUN cat /tmp/.env >> /etc/environment && rm /tmp/.env

RUN echo "12 0 * * * /usr/local/bin/github_backup_script.sh >> /var/log/github_backup.log 2>&1" > /tmp/crontab \
    && crontab /tmp/crontab \
    && rm /tmp/crontab

RUN touch /var/log/github_backup.log

COPY .gitconfig /root/.gitconfig

CMD ["cron", "-f"]
