#!/bin/bash

[[ "$BASH_SOURCE" == "$0" ]] && {
    echo "Please 'source' this script, don't execute it directly"
    echo "e.g.:"
    echo "$ source $0"
    return 1 2> /dev/null || exit 1
}

export OS_AUTH_URL="https://cloud.api.selcloud.ru/identity/v3"
export OS_IDENTITY_API_VERSION="3"
export OS_VOLUME_API_VERSION="3"

export CLIFF_FIT_WIDTH=1

export OS_PROJECT_DOMAIN_NAME='434641'
export OS_PROJECT_ID='92e9cd27a36b4be5a8b78685e6dd7a3e'
export OS_TENANT_ID='92e9cd27a36b4be5a8b78685e6dd7a3e'
export OS_REGION_NAME='ru-7'

export OS_USER_DOMAIN_NAME='434641'
export OS_USERNAME='sa-admin'

echo "Please enter your OpenStack Password: "
read -sr OS_PASSWORD_INPUT
export OS_PASSWORD=$OS_PASSWORD_INPUT
