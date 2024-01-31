# Single Node CDP PVC-Base Cluster 

This script automatically sets up a CDP PVC-Base (aka CDP Data Center) Trial cluster on the public cloud on a single VM with the services preconfigured in a template file. It supports both clusters with or without kerberos.  Trial cluster licenses last 60 days.  You can install your own license file for longer use.

This cluster is meant to be used for demos, experimenting, training, and workshops so it is only one node and does not have TLS enabled.  One node clusters are not production supported configurations.

## Instructions

Below are instructions for creating the cluster.

### Provisioning Cluster
- Create a Centos 7 VM with at least 8 vCPUs/ 32 GB RAM. Choose the plain vanilla Centos image, not a cloudera-centos image.
- OS disk size: at least 50 GB.  120 GB recommended so you have room for some data.


### Provisioning Cluster with Trial parcels

Currently, there is no automation process to download parcels not in a Cloudera archive repository. You need to download the required files from the official Cloudera website on your laptop. Then, sftp the `.parcel`, `.sha` and `.jar` files into the `/home/centos` or `/root` directory. The script takes care of placing these files into the correct folders during installation.

For example, you can install a seperately provided parcel once your host looks like the below:

```
$ ls -l /root/
-rwxr-xr-x. 1 centos centos 148855790 Aug  5 18:41 MYPARCEL-0.7.0.1.0.0.0-11-el7.parcel
-rw-r--r--. 1 centos centos        41 Aug  5 18:41 MYPARCEL-0.7.0.1.0.0.0-11-el7.parcel.sha
-rwxr-xr-x. 1 centos centos     14525 Aug  5 18:41 MYPARCEL-0.7.0.jar
```

To install seperate provded parcels, you must provide your own CM template file, like `cmtemplatewithmyapp.json`.

### Configuration and installation
- If you created the VM on Azure and need to resize the OS disk, here are the [instructions](scripts/how-to-resize-os-disk.md).
- add 2 inbound rules to the Security Group:
  - to allow your PC IP only, for all ports.
  - to allow the VM's own IP, for all ports.
- ssh into VM and copy this repo.

```
sudo su -
yum install -y git
git clone https://github.com/fabiog1901/SingleNodeCDPCluster.git
cd SingleNodeCDPCluster
chmod 755 setup*.sh
```
Run the desired setup script for yor install.

The scripts `setup*.sh` takes 2 arguments for the 717 trial and 4 arguments for 719:
- arg1 the cloud provider name: `aws`,`azure`,`gcp`.  `gcp` also works for many others.
- arg2 the template file.
- arg3 the download user ID - not used for trial download releases outside the paywall
- arg4 the download password - not used for trial download releases outside the paywall

Wait until the script finishes, check for any errors - a few of them are normal errors.

Example: create 7.1.7 cluster for CentOS 7 on AWS using a default 717 template json
```
$ ./setup.sh aws templates/base.json
```

Example: create 7.1.7 cluster for CentOS 7 on Azure using a default 717 template json
```
$ ./setup.sh azure templates/base.json
```

Example: create 7.1.9 cluster for CentOS 7 on AWS using a default 719 template.json
```
$ ./setupcm7113.sh aws templates/719base.json <my_download_userID> <my_download_password>
```

Example: create 7.1.7 kerberized cluster for CentOS 7 on AWS using a default template
```
$ curl -sSL https://gist.github.com/abajwa-hw/bca3d23fe146c3ebd59a9b5fd19480a3/raw | sudo -E sh
$ ./setup_krb.sh aws templates/wwbank_krb.json

#Optional - Add worldwide bank demo using script
$ curl -sSL https://raw.githubusercontent.com/abajwa-hw/masterclass/master/ranger-atlas/setup-dc-703.sh | sudo -E bash
#demo instructions:
https://community.cloudera.com/t5/Community-Articles/How-to-setup-Cloudera-Security-Governance-GDPR-Worldwide/ta-p/297315
```

Example: create 7.1.9 kerberized cluster for CentOS 7 on AWS using a default template
```
$ curl -sSL https://gist.github.com/abajwa-hw/bca3d23fe146c3ebd59a9b5fd19480a3/raw | sudo -E sh
$ ./setupcm7113krb.sh aws templates/wwbank_krb719.json <my_download_userID> <my_download_password>

#Optional - Add worldwide bank demo using script
$ curl -sSL https://raw.githubusercontent.com/abajwa-hw/masterclass/master/ranger-atlas/setup-dc-703.sh | sudo -E bash
#demo instructions:
https://community.cloudera.com/t5/Community-Articles/How-to-setup-Cloudera-Security-Governance-GDPR-Worldwide/ta-p/297315
```

## Use Notes
Once the script starts creating a cluster, you can open Cloudera Manager at [http://\<public-IP\>:7180](http://<public-IP>:7180)

Wait about 20 minutes for the full cluster install to complete.  You can view the progress in CM.

If you want to create your own cluster from the CM UI, comment out the create cluster command at the 
bottom of the script.  
You can then login to CM and use the UI to create a cluster with desired services.

You can save a cluster template from a working install. See save_template.py in scripts dir. Change cluster name in script 
if you are using a different cluster name.  You will need to edit the saved template you save slightly to change hostname, 
passwords, archive repository locations, and a couple of others. Delete the cluster node list snipet. The other templates 
can be used as examples. When saving a template from an install that used your download user:pass make sure to remove that
private info before sharing the template with others.

The health checks in CM will show some errors which are normal since this is single node cluster. CDP was designed to run 
on clusters with multiple nodes.  For example you could supress the HDFS health check error showing blocks aren't being 
replicated to another cluster.
