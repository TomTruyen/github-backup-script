#!/usr/bin/bash

set -e

# Source the environment variables from the .env file
source /etc/environment

RESET_COLOR="\\033[0m"
RED_COLOR="\\033[0;31m"
YELLOW_COLOR="\\033[0;33m"
GREEN_COLOR="\\033[0;32m"

function reset_color() {
    echo -e "${RESET_COLOR}\\c"
}

function red_color() {
    echo -e "${RED_COLOR}\\c"
}

function green_color() {
    echo -e "${GREEN_COLOR}\\c"
}

function yellow_color() {
	echo -e "${YELLOW_COLOR}\\c"
}

green_color
now=$(date)
echo "Starting GitHub Backup [${now}]"
echo
reset_color

### -------------- ###
### Check for curl ###
### -------------- ###
if ! [ "$(command -v curl)" ]; then
    red_color
    echo "You don't have installed curl"
    exit 1
else
    green_color
    echo "curl is present on your machine, continue..."
fi
reset_color

### ------------ ###
### Check for jq ###
### ------------ ###
if ! [ "$(command -v jq)" ]; then
    red_color
    echo "You don't have installed jq"
    exit 1
else
    green_color
    echo "jq is present on your machine, continue..."
fi
reset_color

### ------------------ ###
### Add GitHub to known hosts ###
### ------------------ ###
green_color
echo
echo "Adding GitHub to known hosts"
ssh-keyscan github.com >> ~/.ssh/known_hosts
reset_color

### ------------------ ###
### Update PATH ###
### ------------------ ###
green_color
echo
echo "Changing path to ${OUTPUT_PATH}"
cd "${OUTPUT_PATH}"
reset_color

### ------------------ ###
### Clone Repositories ###
### ------------------ ###
green_color
echo

page=0
while :; do
    page=$((page+1))

    repositories=$(curl -sf -u "${GITHUB_USERNAME}:${GITHUB_TOKEN}" "https://api.github.com/user/repos?per_page=100&page=${page}&visibility=all&affiliation=owner,organization_member" | jq -c --raw-output ".[] | {name, ssh_url}")

    [ -z "$repositories" ] && break

    for repository in ${repositories}; do
    # Name of Repository (Used to check if we have to pull or clone)
    name=$(jq -r ".name" <<< $repository)
    # SSH URL of repository (Required SSH key setup in GitHub, this can also be replaced by html_url so that ssh key is not required) 
    url=$(jq -r ".ssh_url" <<< $repository)

    # URL of repository locally (if it would exist)
    local_url="${OUTPUT_PATH}/${name}" 

    if [[ -d "$local_url" ]]
    then
        echo "Pulling ${url}..."
        cd "${local_url}"
		reset_color
        if ! git pull --rebase --quiet; then
            yellow_color
            echo "Detected dubious ownership in repository at '${local_url}'"
            git config --global --add safe.directory "${local_url}"
            green_color
            echo "Added '${local_url}' to safe.directory"
            git pull --rebase --quiet
        fi
        cd "${OUTPUT_PATH}"
    else
        echo "Cloning ${url}..."
		reset_color
        if ! git clone --quiet "${url}"; then
            yellow_color
            echo "Detected dubious ownership in repository at '${local_url}'"
            git config --global --add safe.directory "${local_url}"
            green_color
            echo "Added '${local_url}' to safe.directory"
            git clone --quiet "${url}"
        fi
    fi

	green_color
	echo "Repository ${name} backed up successfully"
    done
done

green_color
echo
echo "All your repositories are successfully cloned in ${OUTPUT_PATH}"
echo
reset_color

### ------ ###
### Footer ###
### ------ ###
green_color
now=$(date)
echo "Local GitHub Backup is up-to-date [${now}]"
reset_color