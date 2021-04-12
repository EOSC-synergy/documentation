#!/bin/bash

#source ~/fedcli/bin/activate

# Cmdline Processing:
usage(){
    echo "$0" >&2
    echo "" >&2
    echo "Commands:" >&2
    echo "--site <SITE>       Specify Site (or set via export EGI_SITE)" >&2
    echo "--vo   <VO>         Specify VO   (or set via export EGI_VO)" >&2
    echo -e "\nUse as:\n    eval \`$0\` [<commnd> [<command>]]\n" >&2
}
while [ $# -gt 0 ]; do
    case "$1" in
    -h|--help)          usage;        exit 0                        ;;
    --site)             EGI_SITE=${2};                      shift   ;;
    --vo)               EGI_VO=${2};                        shift   ;;
    esac
    shift
done

unset CHECKIN_CLIENT_ID CHECKIN_CLIENT_SECRE CHECKIN_REFRESH_TOKEN

# Site Selection
[ -z $EGI_SITE ] && {
    echo "You have not chosen a site, please specify with '--site'  (or via export EGI_SITE)" >&2
    echo "" >&2
    echo "Available Sites:" >&2
    fedcloud site list | sed s"/^/    /" >&2
    exit 1
}
[ -z $EGI_VO ] && {
    echo "You have not chosen a VO yet, please specify with '--vo'  (or via export EGI_VO)" >&2
    echo "" >&2
    echo "Available VOs for site '${EGI_SITE}':" >&2
    fedcloud site show --site ${EGI_SITE}| grep name | cut -d : -f 2 | sed s"/^/   /" >&2
    exit 2
}
export EGI_SITE
export EGI_VO

echo "Setting up environment for ${EGI_SITE} / ${EGI_VO}" >&2

# OIDC
OIDC_AGENT_ACCOUNT=egi
eval `oidc-keychain --accounts ${OIDC_AGENT_ACCOUNT}` >/dev/null
export OIDC_ACCESS_TOKEN=`oidc-token ${OIDC_AGENT_ACCOUNT}`

#PROJECT_ID=`fedcloud site show-project-id --vo ${EGI_VO} --site ${EGI_SITE} |grep PROJECT|cut -d '=' -f 2|cut -d ' ' -f 2`
# This sets OS_PROJECT_ID:
eval "$(fedcloud site show-project-id --vo ${EGI_VO} --site ${EGI_SITE} |grep PROJECT)"
export PROJECT_ID=$OS_PROJECT_ID

### Set these variables
# OS_AUTH_URL
# OS_AUTH_TYPE
# OS_IDENTITY_PROVIDER
# OS_PROTOCOL
# OS_ACCESS_TOKEN
eval "$(fedcloud endpoint env --project-id ${PROJECT_ID})"

# Set OS_TOKEN:
eval "$(fedcloud endpoint token)"

export OS_AUTH_TOKEN=${OS_TOKEN}
export OS_AUTH_TYPE=v3token

export OS_STORAGE_URL=`fedcloud openstack catalog list --json-output |jq -r  '.[].Result[] | select(.Name == "swift") | .Endpoints[] | select(.interface == "public") | .url '`


# finally: pass output:

echo "export EGI_SITE=${EGI_SITE}"
echo "export EGI_VO=${EGI_VO}"
echo "export OS_STORAGE_URL=${OS_STORAGE_URL}"
echo "export OS_AUTH_TYPE=${OS_AUTH_TYPE}"
echo "export OS_AUTH_TOKEN=${OS_AUTH_TOKEN}"
echo "export OS_ACCESS_TOKEN=${OS_ACCESS_TOKEN}"
echo "export OS_PROTOCOL=${OS_PROTOCOL}"
echo "export OS_IDENTITY_PROVIDER=${OS_IDENTITY_PROVIDER}"
echo "export OS_AUTH_URL=${OS_AUTH_URL}"
echo "export PROJECT_ID=${PROJECT_ID}"
echo "export OIDC_ACCESS_TOKEN=${OIDC_ACCESS_TOKEN}"



echo "Done" >&2

echo -e "\nYou can now look at available endpoints via:"
echo -e "fedclout openstack catalog list"
echo -e "\nIf there is a `swift` endpoint, you can use it with the appropriate rclone config like this:"
echo -e "\n   `rclone lsd myswift:` (note the ending ':'" 
echo -e "\n   `rclone ls myswift:` (note the ending ':'" 
