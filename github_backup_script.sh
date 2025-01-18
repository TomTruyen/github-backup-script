#!/usr/bin/bash

set -e

RESET_COLOR="\\033[0m"
RED_COLOR="\\033[0;31m"
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

	repositories=$(curl -sf -u "${GITHUB_USERNAME}:${GITHUB_TOKEN}" "https://api.github.com/user/repos?per_page=100&page=${page}&visibility=all&affiliation=owner" | jq -c --raw-output ".[] | {name, ssh_url}")

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
	    git pull --quiet
	    cd "${OUTPUT_PATH}"
	else
	    echo "Cloning ${url}..."
	    git clone --quiet "${url}"
	fi
	done
done

green_color
echo
echo "All your ${repository_count} repositories are successfully cloned in ${OUTPUT_PATH}"
echo
reset_color


### ------ ###
### Footer ###
### ------ ###
green_color
now=$(date)
echo "Local GitHub Backup is up-to-date [${now}]"
reset_color
