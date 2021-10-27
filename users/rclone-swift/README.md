# Using rclone with Openstack Swift

The rclone tool is a popular user tool for syncronization, copying, listing and other
usual file and directory operations between many types of storage systems. The documentation
can be found [here](https://rclone.org/).

## Initial setup

This manual explains how to use rclone with Openstack Swift object store and using the
federated Identity Management service EGI Checkin through the OpenID connect protocol.

Follow these instructions:
1. Clone this repository and change into this directory.
1. Install [rclone](https://rclone.org/install/)
1. Install [jq](https://stedolan.github.io/jq/)
1. Install two python packages:
	1. `fedcloudclient`, see [here](https://fedcloudclient.fedcloud.eu/install.html)
	1. `python-openstackclient`, see [here](https://pypi.org/project/python-openstackclient/)
1. Execute the procedure explained [here](https://docs.egi.eu/users/cloud-compute/auth/#check-in-and-access-tokens) to access and use the EGI Check-in service.
	1. Setup oidc-agent as described [here](https://indigo-dc.gitbook.io/oidc-agent/user/oidc-gen/provider/egi).

## Configure rclone remote

Add the following section to your rclone config file `~/.config/rclone/rclone.conf`:
```
[myswift]
type = swift
env_auth = true
```

This will configure a remote `myswift`, which will get all further configuration from the Openstack
environment variables, as will be shown in the next section.

## Load environment

At this stage we assume you have installed rclone, fedcloud and the openstack cli, as well as
followed the procedures to register in the EGI Checkin and authorize the fedcloud client to
access your checkin account.

You can now use the script to set the environment variables for rclone.
The script may prompt you for more information or if it detects missing dependencies.

```bash
source rclone-swift-env
```

The set environment variables will look similar to these:

```bash
OS_AUTH_URL=https://stratus.ncg.ingrid.pt:5000/v3
OS_STORAGE_URL=https://stratus-stor.ncg.ingrid.pt:8080/swift/v1/AUTH_<project id>
OS_AUTH_TOKEN=<...>
```

The script tries to determine a storage endpoint.
If you want to use a specific endpoint proceed to the next section.
You can now use the rclone remote:
```bash
rclone lsd myswift:
    14296226 2021-03-01 11:10:28         1 somedir

rclone ls myswift:
 14296226 rclone-v1.54.0-linux-amd64.deb
```

### Optional: Determine storage endpoint manually
You can determine the storage endpoint manually using the catalog:

```bash
fedcloud openstack catalog list
```

In particular you will obtain the endpoint:

```
| swift | object-store | RegionOne                  |
|       |              | public: https://stratus-stor.ncg.ingrid.pt:8080/swift/v1/AUTH_05e52356addc44e18ef2bd14f2e2f67d   |
```

To use a storage endpoint export its url and use rclone as indicated above:

```bash
export OS_STORAGE_URL=<endpoint url>
```
