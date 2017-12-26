#!/bin/bash

# ----------- UTILS FUNCTIONS -----------

# Printer with shell colors
function utils.printer {
    # BASH COLORS
    GREEN=`tput setaf 2`
    RESET=`tput sgr0`
    echo -e "${GREEN}$1${RESET}"
}

# Check container status and PORT status
function utils.checkContainerPortStatus {
    if [[ ! -z $1 ]] && [[ ! -z $2 ]]; then
        while [[ $(docker inspect --format='{{.State.Status}}' $1) == "running" ]] || [[ ! -z "$(lsof -i :$2)" ]]; do
            utils.printer "Waiting for \"$1\" stop and free \"$2\" PORT"
            sleep 1
        done
    fi
}


# ------------ MAIN SCRIPT ---------------

# Docker container service names
NGINX_SERVICE_CONTAINER=blog_nginx_1
CERTBOT_SERVICE_CONTAINER=blog_certbot_1

utils.printer "Step 0: Check configuration vars"
if [[ ! -z $NGINX_SERVICE_CONTAINER ]] && [[ ! -z $CERTBOT_SERVICE_CONTAINER ]]; then
    utils.printer "Step 1: Stop nginx service"
    docker stop $NGINX_SERVICE_CONTAINER
    utils.checkContainerPortStatus $NGINX_SERVICE_CONTAINER 80

    utils.printer "Step 2: Create or renew certificates"
    utils.printer "Start cerbot service"
    docker restart $CERTBOT_SERVICE_CONTAINER
    utils.checkContainerPortStatus $CERTBOT_SERVICE_CONTAINER 80

    utils.printer "Step 3: Restart nginx service"
    docker restart $NGINX_SERVICE_CONTAINER
else
    utils.printer "Something is wrong, one ore more configuration vars are empty"
fi
