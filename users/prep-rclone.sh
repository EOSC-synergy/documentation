#!/bin/bash

source ~/fedcli/bin/activate

# OIDC
unset CHECKIN_CLIENT_ID CHECKIN_CLIENT_SECRE CHECKIN_REFRESH_TOKEN EGI_SITE 
OIDC_AGENT_ACCOUNT=egi
eval `oidc-keychain --accounts ${OIDC_AGENT_ACCOUNT}`
export OIDC_ACCESS_TOKEN=`oidc-token ${OIDC_AGENT_ACCOUNT}`

# Site Selection
# FIXME: Make this cmdline based
EGI_SITE=NCG-INGRID-PT
EGI_VO=covid19.eosc-synergy.eu
#PROJECT_ID=`fedcloud site show-project-id --vo ${EGI_VO} --site ${EGI_SITE} |grep PROJECT|cut -d '=' -f 2|cut -d ' ' -f 2`
# This sets OS_PROJECT_ID:
eval "$(fedcloud site show-project-id --vo ${EGI_VO} --site ${EGI_SITE} |grep PROJECT)"
export PROJECT_ID=$OS_PROJECT_ID

eval "$(fedcloud endpoint env --project-id ${PROJECT_ID})"
eval "$(fedcloud endpoint token)"

export OS_AUTH_TOKEN=${OS_TOKEN}
export OS_AUTH_TYPE=v3token
export OS_STORAGE_URL=https://stratus-stor.ncg.ingrid.pt:8080/swift/v1/AUTH_${PROJECT_ID}
