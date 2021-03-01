# Using rclone with Openstack Swift

## Introduction

The rclone tool is a popular user tool for syncronization, copying, listing and other
usual file and directory operations between many types of storage systems, the documentation
can be found here - https://rclone.org/ .

This manual explains how to use rclone with Openstack Swift object store and using the
federated Identity Management service EGI Checkin through the OpenID connect protocal.

We will use the following user tools:

* rclone - https://rclone.org/downloads/
* egicli - https://github.com/EGI-Foundation/egicli
* Openstack CLI - https://docs.openstack.org/newton/user-guide/common/cli-install-openstack-command-line-clients.html

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

### Leave everything else blanck
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
vi egi-cli.sh

#!/bin/bash
unset CHECKIN_CLIENT_ID CHECKIN_CLIENT_SECRE CHECKIN_REFRESH_TOKEN EGI_SITE 
export CHECKIN_CLIENT_ID=<YOUR_CLIENT_ID>
export CHECKIN_CLIENT_SECRET=<YOUR_CLIENT_SECRET>
export CHECKIN_REFRESH_TOKEN=<YOUR_REFRESH_TOKEN>
export EGI_SITE=<YOUR_PREFERED_FEDCLOUD_SITE>
```

In this example we have chosen `EGI_SITE=NCG-INGRID-PT`.

The following example is taken from https://docs.egi.eu/users/cloud-compute/auth/ to do
two things: Discover which openstack projects you have access at that site, and to set
the openstack environment variables to access resources at that site:

```bash
source egi-cli.sh
egicli endpoint projects
```

You can choose the project ID you want to use, and run:

```bash
eval "$(egicli endpoint env --project-id <PROJECT_ID>)"
```

This will set all needed environment openstack variables, namely:

```bash
OS_ACCESS_TOKEN=e...
OS_AUTH_TYPE=v3oidcaccesstoken
OS_AUTH_URL=https://stratus.ncg.ingrid.pt:5000/v3
OS_IDENTITY_PROVIDER=egi.eu
OS_PROJECT_ID=zzz
OS_PROTOCOL=openid
```

We will need to get a keystone unscoped token from this access token:

```bash
openstack token issue
+------------+----------------------------------+
| Field      |Value                             |
+------------+----------------------------------+
| expires    | 2021-03-01T15:03:26+0000         |
| id         | gAAAAAB....                      |
| project_id | 05e52356addc44e18ef2bd14f2e2f67d |
| user_id    | 18871297addc4bc7af376f1fa511ed94 |
+------------+----------------------------------+
```

You should set the following environment variable:

```bash
export OS_AUTH_TOKEN=gAAAAAB....
```

And you will need the swift sotrage endpoint from the catalog:

```bash
openstack catalog list
```

In particular you will obtain the endpoint:

```
| swift     | object-store | RegionOne                  |
|           |              | public: https://stratus-stor.ncg.ingrid.pt:8080/swift/v1/AUTH_05e52356addc44e18ef2bd14f2e2f67d   |
```

Set the following environment variable:

```bash
export OS_STORAGE_URL=https://stratus-stor.ncg.ingrid.pt:8080/swift/v1/AUTH_05e52356addc44e18ef2bd14f2e2f67d
```

And the `OS_AUTH_TYPE` needs to be overidden:

```bash
export OS_AUTH_TYPE=v3token
```

The list of environment variables that need to be set are:

```bash
OS_AUTH_TOKEN=gAAAAAB....
OS_AUTH_TYPE=v3token
OS_AUTH_URL=https://stratus.ncg.ingrid.pt:5000/v3
OS_PROJECT_ID=<the projectID>
OS_STORAGE_URL=https://stratus-stor.ncg.ingrid.pt:8080/swift/v1/AUTH_<the projectID>
```

The maybe other openstack variables that are set but are not needed. At this point you
can use rclone with the openstack swift remote:

```bash
rclone lsd myswift:
    14296226 2021-03-01 11:10:28         1 somedir

rclone ls myswift:
 14296226 rclone-v1.54.0-linux-amd64.deb
```
