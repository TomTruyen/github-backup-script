# GitHub Backup Script

A shell script for Linux that automatically backs up your GitHub repositories to your external hard drive.

## What does it do?

This script backs up all **OWNED** repositories, including **private** ones.

If you also want to back up repositories that are part of an organization, follow these steps:

1. **Modify the API query**: Either:
   - **Remove** `&affiliation=owner` from the `curl` request, or
   - **Update** the request URL to:
     ```bash
     'https://api.github.com/user/repos?per_page=100&page=${page}&visibility=all&affiliation=owner,collaborator,organization_member'
     ```
     This change ensures that the script backs up repositories where you are an **owner**, **collaborator**, or **organization member** (the default affiliation).

For more details about the GitHub API endpoint, visit: [GitHub Repositories API Documentation](https://docs.github.com/en/rest/reference/repos#list-repositories-for-the-authenticated-user)

## Setup

1. **Copy the `.env.example` file** to `.env`:

   ```bash
   cp .env.example .env

   ```

2. **Set the values in the** `.env` file:

   - GITHUB_USERNAME: Your GitHub username (e.g., TomTruyen)
   - GITHUB_TOKEN: Your GitHub access token (e.g., abcdefghij123456798) - Generate it at [GitHub Token Settings](https://github.com/settings/tokens)
   - OUTPUT_PATH: The location where you want your backups to be saved (e.g., ~/Desktop/Backups)

3. **Ensure you have your SSH key stored in** `~/.ssh`:

   - `id_ed25519` and `id_ed25519.pub` should be present in the `~/.ssh` directory.
   - If you use a different SSH key, modify the Dockerfile to copy the correct key files.

## Run

To start the script using Docker, run:

```bash
docker-compose up -d --build
```

## Errors

### Bad Interpreter

```bash
bash: ./github_backup_script.sh: /usr/bin/bash^M: bad interpreter: No such file or directory
```

**Solution**

1. Install `dos2unix`

```bash
sudo apt install dos2unix
```

2. Convert the script

```bash
dos2unix -k -o github_backup_script.sh
```

3. Try to run it again
