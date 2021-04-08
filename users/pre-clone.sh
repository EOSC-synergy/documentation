#!/bin/bash


# If using oidc-agent for providing access token, set the account name here
# otherwise comment out following two lines

export OIDC_AGENT_ACCOUNT=egi
eval `oidc-keychain --accounts ${OIDC_AGENT_ACCOUNT}`

# If providing access token directly,e.g. from  https://aai.egi.eu/fedcloud/
# uncomment the following line and set access token there

export OIDC_ACCESS_TOKEN=`oidc-token ${OIDC_AGENT_ACCOUNT}`

# Set site and VO

export EGI_SITE=NCG-INGRID-PT
export EGI_VO=covid19.eosc-synergy.eu


# Beginning of the script
# Do not change following lines

unset OS_ACCESS_TOKEN OS_AUTH_TYPE OS_AUTH_URL OS_IDENTITY_PROVIDER OS_PROJECT_ID OS_PROTOCOL OS_TOKEN OS_AUTH_TOKEN

export OS_STORAGE_URL=`fedcloud openstack catalog list --json-output |jq -r  '.[].Result[] | select(.Name == "swift") | .Endpoints[] | select(.interface == "public") | .url '`

eval `fedcloud site show-project-id`
eval "$(fedcloud endpoint env --project-id ${OS_PROJECT_ID})"
eval "$(fedcloud endpoint token)"

export OS_AUTH_TOKEN=${OS_TOKEN}
export OS_AUTH_TYPE=v3token
