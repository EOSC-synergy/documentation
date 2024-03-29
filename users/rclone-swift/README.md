# Using rclone with Openstack Swift

The rclone tool is a popular user tool for syncronization, copying, listing and other
usual file and directory operations between many types of storage systems. The documentation
can be found at [https://rclone.org/](https://rclone.org/).


To use rclone with Openstack Swift, a set of environment variables have to
be set-up. The concept is, that we use your Federated Account
(EGI-Checkin, eduTEAMS, ...) to authenticate in the context of a VO (that
you choose) with a specific site (that you choose).


## Prerequisites

Follow these instructions first:
1. Install [rclone](https://rclone.org/install/)
1. Follow the Instructions of the [EGI Swift Finder](https://github.com/lburgey/egiSwiftFinder)


## Load environment

Use the [EGI Swift Finder](https://github.com/lburgey/egiSwiftFinder) to
setup your environment. This will look like this:

```bash
$ source swift_finder
✔ oidc-agent account: egi
✔ VO: eosc-synergy.eu
Searching sites providing swift for this VO
Found 2 sites providing swift
✔ Site: NCG-INGRID-PT
export OS_AUTH_TOKEN=.....
export OS_AUTH_URL=https://..........
export OS_STORAGE_URL=https://..........
✔ rclone remote: myswift

You can now use the rclone remote myswift like so:
	'rclone lsd myswift:'
```

You can now use the rclone remote: (note the ending `:`)
```bash
rclone lsd myswift:
    14296226 2021-03-01 11:10:28         1 somedir

rclone ls myswift:
 14296226 rclone-v1.54.0-linux-amd64.deb
```


<!--### Optional: Determine storage endpoint manually-->
<!--You can determine the storage endpoint manually using the catalog:-->
<!---->
<!--```bash-->
<!--fedcloud openstack catalog list-->
<!--```-->
<!---->
<!--In particular you will obtain the endpoint:-->
<!---->
<!--```-->
<!--| swift | object-store | RegionOne                  |-->
<!--|       |              | public: https://stratus-stor.ncg.ingrid.pt:8080/swift/v1/AUTH_05e52356addc44e18ef2bd14f2e2f67d   |-->
<!--```-->
<!---->
<!--To use a storage endpoint export its url and use rclone as indicated above:-->
<!---->
<!--```bash-->
<!--export OS_STORAGE_URL=<endpoint url>-->
<!--```-->
