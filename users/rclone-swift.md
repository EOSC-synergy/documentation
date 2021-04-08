# Using rclone with Openstack Swift

## Introduction

The rclone tool is a popular user tool for syncronization, copying, listing and other
usual file and directory operations between many types of storage systems, the documentation
can be found here - https://rclone.org/ .

This manual explains how to use rclone with Openstack Swift object store and using the
federated Identity Management service EGI Checkin through the OpenID connect protocal.

We will use the following user tools:

* rclone - https://rclone.org/downloads/
* fedcloud - https://fedcloudclient.fedcloud.eu/

Furthemore, you will need to execute the procedure explained here - https://docs.egi.eu/users/
to access and use the EGI Check-in service. In particular:

* https://docs.egi.eu/users/cloud-compute/auth/

## Configure the rclone remote

The rclone remote we will configure is of the type `swift and you can configure it by
executing:

```
rclone config

e/n/d/r/c/s/q> n
name> myswift

Type of storage to configure.
Storage> swift

2 / Get swift credentials from environment vars. Leave other fields blank if using this.
   \ "true"
env_auth> true

### Leave everything else blank
```

You should now have you rclone.conf with the remote you just configured:

```
cat rclone.conf

[myswift]
type = swift
env_auth = true

```

This means that the remote will get all configuration from the Openstack 
environment variables, as will be shown in the next section.

## HOWTO use

At this stage we assume you have installed rclone, egicli and the openstack cli, as well as
followed the procedures to register in the EGI Checkin and authorize the fedcloud client to
access your checkin account.

With this procedures you will get:

* a client id
* a client secret
* a refresh token

For easy use you can create the following script to set the environment variables for the egicli:

```bash
vi prep-rclone.sh

#!/bin/bash

source ~/fedcli/bin/activate

unset CHECKIN_CLIENT_ID CHECKIN_CLIENT_SECRE CHECKIN_REFRESH_TOKEN EGI_SITE 
export OIDC_AGENT_ACCOUNT=egi
eval `oidc-keychain --accounts ${OIDC_AGENT_ACCOUNT}`
export OIDC_ACCESS_TOKEN=`oidc-token ${OIDC_AGENT_ACCOUNT}`

export EGI_SITE=NCG-INGRID-PT
export EGI_VO=covid19.eosc-synergy.eu
export PROJECT_ID=`fedcloud site show-project-id |grep PROJECT|cut -d ':' -f 2|cut -d ' ' -f 2`

eval "$(fedcloud endpoint env --project-id ${PROJECT_ID})"
eval "$(fedcloud endpoint token)"

export OS_AUTH_TOKEN=${OS_TOKEN}
export OS_AUTH_TYPE=v3token
export OS_STORAGE_URL=https://stratus-stor.ncg.ingrid.pt:8080/swift/v1/AUTH_${PROJECT_ID}
```

In this example we have chosen `EGI_SITE=NCG-INGRID-PT` and the VO is covid19.eosc-synergy.eu.

```bash
source prep-rclone.sh
```

This will set all needed environment openstack variables, namely:

```bash
OS_ACCESS_TOKEN=e...
OS_AUTH_URL=https://stratus.ncg.ingrid.pt:5000/v3
OS_IDENTITY_PROVIDER=egi.eu
OS_PROJECT_ID=${PROJECT_ID}
OS_PROTOCOL=openid
OS_AUTH_TYPE=v3token
OS_STORAGE_URL=https://stratus-stor.ncg.ingrid.pt:8080/swift/v1/AUTH_${PROJECT_ID}
```

You can get the storage endpoint from the catalog:

```bash
openstack catalog list
```

In particular you will obtain the endpoint:

```
| swift     | object-store | RegionOne                  |
|           |              | public: https://stratus-stor.ncg.ingrid.pt:8080/swift/v1/AUTH_05e52356addc44e18ef2bd14f2e2f67d   |
```

There maybe other openstack variables that are set but are not needed. At this point you
can use rclone with the openstack swift remote:

```bash
rclone lsd myswift:
    14296226 2021-03-01 11:10:28         1 somedir

rclone ls myswift:
 14296226 rclone-v1.54.0-linux-amd64.deb
```
