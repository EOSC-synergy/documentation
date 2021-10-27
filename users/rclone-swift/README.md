# Using rclone with Openstack Swift

The rclone tool is a popular user tool for syncronization, copying, listing and other
usual file and directory operations between many types of storage systems, the documentation
can be found [here](https://rclone.org/).

## Initial setup

This manual explains how to use rclone with Openstack Swift object store and using the
federated Identity Management service EGI Checkin through the OpenID connect protocol.

Follow these instructions:
1. Install [rclone](https://rclone.org/downloads/)
2. Install the [fedcloud client](https://fedcloudclient.fedcloud.eu/)
3. Install [jq](https://stedolan.github.io/jq/)
4. Execute the procedure explained [here](https://docs.egi.eu/users/),
in particular [this section](https://docs.egi.eu/users/cloud-compute/auth/),
to access and use the EGI Check-in service.

## Configure rclone remote

Add a section like this to your rclone.conf:
```
cat ~/.config/rclone/rclone.conf

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

You can now use the script to set the environment variables for rclone:

```bash
source rclone-swift-env
```

This will set all needed environment openstack variables:

```bash
OS_AUTH_URL=https://stratus.ncg.ingrid.pt:5000/v3
OS_STORAGE_URL=https://stratus-stor.ncg.ingrid.pt:8080/swift/v1/AUTH_<project id>
OS_AUTH_TOKEN=<...>
```

In case the script does not detect any storage endpoints, proceed to the next section.
Otherwise, you can now use the rclone remote:
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
| swift     | object-store | RegionOne                  |
|           |              | public: https://stratus-stor.ncg.ingrid.pt:8080/swift/v1/AUTH_05e52356addc44e18ef2bd14f2e2f67d   |
```

To use an storage endpoint export its url and use rclone as indicated above:

```bash
export OS_STORAGE_URL=<public endpoint url>
```
